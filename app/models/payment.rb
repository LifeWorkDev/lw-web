class Payment < ApplicationRecord
  include Payments::Status

  monetize :amount_cents, with_model_currency: :currency, numericality: {greater_than_or_equal_to: 0}
  monetize :stripe_fee_cents, numericality: {greater_than_or_equal_to: 0}

  belongs_to :pays_for, polymorphic: true
  belongs_to :pay_method
  belongs_to :user, optional: true
  has_one :disbursement_line, -> { credits.where(code: :disbursement) }, as: :detail, class_name: "DoubleEntry::Line", dependent: :destroy, inverse_of: :detail
  has_one :payment_line, -> { credits.where(code: :payment) }, as: :detail, class_name: "DoubleEntry::Line", dependent: :destroy, inverse_of: :detail
  has_one :refund_line, -> { credits.where(code: :refund) }, as: :detail, class_name: "DoubleEntry::Line", dependent: :destroy, inverse_of: :detail
  has_many :lines, as: :detail, class_name: "DoubleEntry::Line", dependent: :delete_all, inverse_of: :detail

  delegate :client, :client_amount, :client_fees, :client_users, :freelancer, :freelancer_amount, :freelancer_fees, :platform_fee, :processing_fee, to: :pays_for

  pg_search_scope :pg_search,
    against: %i[stripe_id],
    associated_against: {
      pay_method: %i[name issuer kind last_4 stripe_id],
    }

  def charge!
    set_stripe_fields pay_method.charge!(
      amount: amount,
      idempotency_key: pays_for.idempotency_key,
      metadata: pays_for.stripe_metadata,
    )
    record_charge!
    save!
    true
  rescue Stripe::CardError => e
    Errbase.report(e, {payment: id})
    err = e.error
    self.note = err.message
    charge = err.payment_intent&.charges&.first || err.charge
    if charge
      set_stripe_fields(charge)
    else
      self.status = "failed"
    end
    save!
    false
  end

  def issue_refund!(new_amount:, freelancer_refund_cents:)
    raise "new_amount must be type Money" unless new_amount.is_a? Money
    raise "freelancer_refund_cents must be type Integer" unless freelancer_refund_cents.is_a? Integer
    raise "Can't refund a #{status} payment" unless paid?
    raise "Can't increase the amount of a #{status} payment" if new_amount > amount

    client_refund_cents = (amount - new_amount).cents
    self.amount = new_amount

    amount.zero? ? refund!(freelancer_refund_cents) : partially_refund!(client_refund_cents, freelancer_refund_cents)

    ClientMailer.with(recipient: client.primary_contact, payment: self, refund_amount_cents: client_refund_cents).payment_refunded.deliver_later
    FreelancerMailer.with(recipient: freelancer, payment: self, refund_amount_cents: freelancer_refund_cents).payment_refunded.deliver_later
  end

  def set_stripe_fields(charge)
    self.status = charge.status
    self.stripe_id = charge.id
    self.paid_at = Time.zone.at(charge.created)
    self.stripe_fee = Money.new(charge.balance_transaction.fee, charge.balance_transaction.fee_details.first.currency) if charge.balance_transaction
  end

  memoize def stripe_obj
    get_stripe_obj
  end

  def get_stripe_obj
    if stripe_id.start_with? "pi_"
      Stripe::PaymentIntent.retrieve(stripe_id)
    elsif stripe_id.start_with? "ch_", "py_"
      Stripe::Charge.retrieve(stripe_id)
    else
      raise "Unrecognized Stripe ID type: #{stripe_id}"
    end
  end

  def project
    pays_for.try(:project) || pays_for
  end

  def record_refund!(client_refund_cents:, metadata:, freelancer_refund_cents: nil, platform_refund_cents: nil)
    if freelancer_refund_cents.present? # Disbursed payment
      record_reversed_transfer!(Money.new(client_refund_cents, currency), Money.new(freelancer_refund_cents, currency), Money.new(platform_refund_cents, currency), metadata)
    else # Deposited payment
      DoubleEntry.transfer(
        Money.new(client_refund_cents, currency),
        code: :refund,
        detail: self,
        from: freelancer.account_receivable,
        to: client.account_cash,
        metadata: metadata,
      )
    end
  end

  def transfer!
    record_transfer! Stripe::Transfer.create(
      {
        amount: freelancer_amount.cents,
        currency: currency.to_s,
        description: pays_for.to_s,
        destination: freelancer.stripe_id,
        metadata: pays_for.stripe_metadata,
        source_transaction: stripe_id,
      },
      idempotency_key: "#{pays_for.idempotency_key}-transfer-of-#{freelancer_amount.cents}",
    )
    true
  end

private

  def process_refund!(freelancer_refund_cents, client_refund_cents = amount_cents_was)
    return false unless stripe_id.present?

    stripe_refund = Stripe::Refund.create({
      amount: client_refund_cents,
      charge: stripe_id,
      metadata: pays_for.stripe_metadata,
      reason: :requested_by_customer,
    }, idempotency_key: "refund-#{client_refund_cents}-of-payment-#{id}")

    record_job_args = {
      payment: self,
      client_refund_cents: stripe_refund.amount,
      metadata: {refund_id: stripe_refund.id},
    }

    # Has payment been disbursed? Withdraw freelancer refund portion from their account.
    if (transfer_id = disbursement_line&.metadata&.dig("transfer_id"))
      platform_refund_cents = Money.new(platform_fee(freelancer_refund_cents), currency).cents
      reversal_amount_cents = freelancer_refund_cents - platform_refund_cents
      reversal = Stripe::Transfer.create_reversal(transfer_id,
        {amount: reversal_amount_cents,
         metadata: pays_for.stripe_metadata.merge({
           'Refund ID': stripe_refund.id,
           'Refund cents': stripe_refund.amount,
         })},
        idempotency_key: "reversal-#{reversal_amount_cents}-of-transfer-#{transfer_id}")

      record_job_args[:freelancer_refund_cents] = reversal.amount
      record_job_args[:platform_refund_cents] = platform_refund_cents
      record_job_args[:metadata].merge!({
        balance_transaction_id: reversal.balance_transaction,
        destination_payment_refund_id: reversal.destination_payment_refund,
        transfer_id: reversal.transfer,
        transfer_reversal_id: reversal.id,
      })
    end

    Payments::RecordRefundJob.perform_later(record_job_args)
  end

  def record_charge!
    DoubleEntry.transfer(
      amount,
      code: :payment,
      detail: self,
      from: client.account_cash,
      to: freelancer.account_receivable,
    )
  end

  def record_transfer!(transfer)
    metadata = transfer_metadata(transfer)

    DoubleEntry.lock_accounts(freelancer.account_receivable, freelancer.account_disbursement, ACCOUNT_FEES) do
      DoubleEntry.transfer(
        freelancer_amount,
        code: :disbursement,
        detail: self,
        from: freelancer.account_receivable,
        to: freelancer.account_disbursement,
        metadata: metadata,
      )

      if platform_fee.positive?
        DoubleEntry.transfer(
          platform_fee,
          code: :platform,
          detail: self,
          from: freelancer.account_receivable,
          to: ACCOUNT_FEES,
          metadata: metadata,
        )
      end

      if processing_fee.positive?
        DoubleEntry.transfer(
          processing_fee,
          code: :processing,
          detail: self,
          from: freelancer.account_receivable,
          to: ACCOUNT_FEES,
          metadata: metadata,
        )
      end
    end
  end

  # WIP: used once to reverse a disbursed milestone for Marina Emery. Check/clean up before using
  def record_reversed_disbursement!(transfer_amount, metadata)
    DoubleEntry.lock_accounts(freelancer.account_receivable, freelancer.account_disbursement, ACCOUNT_FEES) do
      DoubleEntry.transfer(
        transfer_amount,
        code: :disbursement_reversal,
        detail: self,
        from: freelancer.account_disbursement,
        to: freelancer.account_receivable,
        metadata: metadata,
      )

      DoubleEntry.transfer(
        platform_amount,
        code: :platform_reversal,
        detail: self,
        from: ACCOUNT_FEES,
        to: freelancer.account_receivable,
        metadata: metadata,
      )

      DoubleEntry.transfer(
        processing_amount,
        code: :processing_reversal,
        detail: self,
        from: ACCOUNT_FEES,
        to: freelancer.account_receivable,
        metadata: metadata,
      )
    end
  end

  def record_reversed_transfer!(client_refund, freelancer_refund, platform_refund, metadata)
    DoubleEntry.lock_accounts(client.account_cash, freelancer.account_disbursement, ACCOUNT_FEES) do
      DoubleEntry.transfer(
        freelancer_refund - platform_refund,
        code: :disbursement_refund,
        detail: self,
        from: freelancer.account_disbursement,
        to: client.account_cash,
        metadata: metadata,
      )

      if platform_refund.positive?
        DoubleEntry.transfer(
          platform_refund,
          code: :platform_refund,
          detail: self,
          from: ACCOUNT_FEES,
          to: client.account_cash,
          metadata: metadata,
        )
      end

      processing_refund = client_refund - freelancer_refund
      if processing_refund.positive?
        DoubleEntry.transfer(
          processing_refund,
          code: :processing_refund,
          detail: self,
          from: ACCOUNT_FEES,
          to: client.account_cash,
          metadata: metadata,
        )
      end
    end
  end

  def transfer_metadata(transfer)
    {
      transfer_id: transfer.id,
      destination_account_id: transfer.destination,
      destination_payment_id: transfer.destination_payment,
      source_transaction_id: transfer.source_transaction,
      transfer_group_id: transfer.transfer_group,
      balance_transaction_id: transfer.balance_transaction,
    }
  end
end
