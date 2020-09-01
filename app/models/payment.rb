class Payment < ApplicationRecord
  include Payments::Status

  monetize :amount_cents, with_model_currency: :currency, numericality: {greater_than: 0}
  monetize :stripe_fee_cents, numericality: {greater_than_or_equal_to: 0}

  belongs_to :pays_for, polymorphic: true
  belongs_to :pay_method
  belongs_to :user, optional: true
  has_one :disbursement_line, -> { credits.where(code: :disbursement) }, as: :detail, class_name: "DoubleEntry::Line", dependent: :destroy, inverse_of: :detail
  has_one :payment_line, -> { credits.where(code: :payment) }, as: :detail, class_name: "DoubleEntry::Line", dependent: :destroy, inverse_of: :detail
  has_one :refund_line, -> { credits.where(code: :refund) }, as: :detail, class_name: "DoubleEntry::Line", dependent: :destroy, inverse_of: :detail
  has_many :lines, as: :detail, class_name: "DoubleEntry::Line", dependent: :delete_all, inverse_of: :detail

  delegate :client, :client_amount, :client_fees, :freelancer, :freelancer_amount, :freelancer_fees, :platform_fee, :processing_fee, to: :pays_for

  def charge!
    set_stripe_fields pay_method.charge!(
      amount: amount,
      idempotency_key: pays_for.idempotency_key,
      metadata: pays_for.stripe_metadata,
    )
    record_charge!
    true
  rescue Stripe::CardError => e
    fail!(e.error.message)
    false
  end

  def issue_refund!(new_amount:, freelancer_refund_cents:)
    raise "Can't issue refund unless payment is deposited" unless deposited?
    raise "Can't refund a deposited payment" if new_amount > amount

    client_refund_cents = (amount - new_amount).cents
    self.amount = new_amount

    amount.zero? ? refund! : partially_refund!(client_refund_cents)

    ClientMailer.with(recipient: client.primary_contact, payment: self, refund_amount_cents: client_refund_cents).payment_refunded.deliver_later
    FreelancerMailer.with(recipient: freelancer, payment: self, refund_amount_cents: freelancer_refund_cents).payment_refunded.deliver_later
  end

  def set_stripe_fields(charge)
    self.status = charge.status
    self.stripe_id = charge.id
    self.stripe_fee = Money.new(charge.balance_transaction.fee, charge.balance_transaction.fee_details.first.currency)
    self.paid_at = Time.zone.at(charge.created)
    save!
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

  def record_refund!(refund_amount_cents, refund_id)
    DoubleEntry.transfer(
      Money.new(refund_amount_cents, currency),
      code: :refund,
      detail: self,
      from: freelancer.account_receivable,
      to: client.account_cash,
      metadata: {refund_id: refund_id},
    )
  end

  def transfer!
    record_transfer! Stripe::Transfer.create(
      {
        amount: transfer_amount.cents,
        currency: currency.to_s,
        description: pays_for.to_s,
        destination: freelancer.stripe_id,
        metadata: pays_for.stripe_metadata,
        source_transaction: stripe_id,
      },
      idempotency_key: "#{pays_for.idempotency_key}-transfer",
    )
    true
  end

private

  def process_refund!(refund_amount_cents = amount_cents)
    return false unless stripe_id.present?

    stripe_refund = Stripe::Refund.create({
      amount: refund_amount_cents,
      charge: stripe_id,
      # Can add reverse_transfer: true to support refunding disbursed payments, but need to add additional accounting lines
    }, idempotency_key: "refund-#{refund_amount_cents}-of-payment-#{id}")
    Payments::RecordRefundJob.perform_later(self, stripe_refund.amount, stripe_refund.id)
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
        transfer_amount,
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

  def transfer_amount
    pays_for.freelancer_amount
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
