class Payment < ApplicationRecord
  include Payments::Status

  monetize :amount_cents, with_model_currency: :currency, numericality: {greater_than_or_equal_to: 0}
  monetize :platform_fee_cents, with_model_currency: :currency, numericality: {greater_than_or_equal_to: 0}
  monetize :processing_fee_cents, with_model_currency: :currency, numericality: {greater_than_or_equal_to: 0}
  monetize :stripe_fee_cents, numericality: {greater_than_or_equal_to: 0}

  belongs_to :pays_for, polymorphic: true
  belongs_to :pay_method
  belongs_to :paid_by, class_name: "User", optional: true, inverse_of: :payments_made
  belongs_to :recipient, class_name: "User", inverse_of: :payments_received
  has_one :disbursement_line, -> { credits.where(code: :disbursement).order(id: :desc) }, as: :detail, class_name: "DoubleEntry::Line", inverse_of: :detail, dependent: :nullify
  has_one :disbursement_refund_line, -> { credits.where(code: :disbursement_refund).order(id: :desc) }, as: :detail, class_name: "DoubleEntry::Line", inverse_of: :detail, dependent: :nullify
  has_one :payment_line, -> { credits.where(code: :payment).order(id: :desc) }, as: :detail, class_name: "DoubleEntry::Line", inverse_of: :detail, dependent: :nullify
  has_one :payout_line, -> { credits.where(code: :payout).order(id: :desc) }, as: :detail, class_name: "DoubleEntry::Line", inverse_of: :detail, dependent: :nullify
  has_one :platform_fee_line, -> { credits.where(code: :platform).order(id: :desc) }, as: :detail, class_name: "DoubleEntry::Line", inverse_of: :detail, dependent: :nullify
  has_one :platform_refund_line, -> { credits.where(code: :platform_refund).order(id: :desc) }, as: :detail, class_name: "DoubleEntry::Line", inverse_of: :detail, dependent: :nullify
  has_one :processing_fee_line, -> { credits.where(code: :processing).order(id: :desc) }, as: :detail, class_name: "DoubleEntry::Line", inverse_of: :detail, dependent: :nullify
  has_one :processing_refund_line, -> { credits.where(code: :processing_refund).order(id: :desc) }, as: :detail, class_name: "DoubleEntry::Line", inverse_of: :detail, dependent: :nullify
  has_one :refund_line, -> { credits.where(code: :refund).order(id: :desc) }, as: :detail, class_name: "DoubleEntry::Line", inverse_of: :detail, dependent: :nullify
  has_many :lines, as: :detail, class_name: "DoubleEntry::Line", dependent: :delete_all, inverse_of: :detail

  scope :milestone, -> { where(pays_for_type: "Milestone") }
  scope :project, -> { where(pays_for_type: "Project") }

  delegate :client, :client_users, :freelancer, to: :pays_for

  alias_method :client_amount, :amount

  pg_search_scope :pg_search,
                  against: %i[stripe_id],
                  associated_against: {
                    pay_method: %i[name issuer kind last_4 stripe_id],
                  }

  def milestone?
    pays_for_type == "Milestone"
  end

  def milestone
    pays_for if milestone?
  end

  def project?
    pays_for_type == "Project"
  end

  memoize def project
    pays_for.try(:project) || pays_for
  end

  memoize def client_fee
    processing_fee + (client_pays_fees? ? platform_fee : 0)
  end

  memoize def amount_before_fees
    amount - client_fee
  end

  def amount_before_fees=(new_amount)
    new_amount = new_amount.to_money
    freelancer_refund = amount_before_fees - new_amount
    return if freelancer_refund.zero?

    new_client_amount = amount - freelancer_refund - project.client_fee(amount: freelancer_refund, pay_method: pay_method, client_pays_fees: client_pays_fees?)
    issue_refund!(new_amount: new_client_amount, freelancer_refund_cents: freelancer_refund.cents)
  end

  memoize def freelancer_fee
    client_pays_fees? ? 0 : platform_fee
  end

  memoize def freelancer_amount
    amount_before_fees - freelancer_fee
  end

  def charge!
    begin
      set_stripe_fields pay_method.charge!(
        amount: amount,
        idempotency_key: pays_for.idempotency_key,
        metadata: payment_metadata,
      )
      record_charge!
      record_stripe_fees!
    rescue Stripe::CardError => e
      Errbase.report(e, {payment: id})
      err = e.error
      self.note = err.message
      charge = err.payment_intent&.charges&.first || err.charge
      if charge
        set_stripe_fields(charge)
      else
        self.status = :failed
      end
    end
    save!
    self
  end

  def issue_refund!(new_amount:, freelancer_refund_cents:)
    raise "new_amount must be type Money" unless new_amount.is_a? Money
    raise "freelancer_refund_cents must be type Integer" unless freelancer_refund_cents.is_a? Integer
    raise "Can't refund a #{status} payment" unless paid?
    raise "Can't increase the amount of a #{status} payment" if new_amount > amount

    client_refund_cents = (amount - new_amount).cents
    self.amount = new_amount
    self.platform_fee_cents -= project.platform_fee(amount: freelancer_refund_cents)
    self.processing_fee_cents -= project.processing_fee(amount: freelancer_refund_cents, pay_method: pay_method)

    if amount.zero?
      refund!(freelancer_refund_cents)
    elsif disbursed?
      process_refund!(freelancer_refund_cents, client_refund_cents)
      save!
    else
      partially_refund!(freelancer_refund_cents, client_refund_cents)
    end

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

  memoize def payout_amount
    (platform_fee + processing_fee - stripe_fee - 0.25.to_money) * (1 - 0.0025)
  end

  def payout!
    return unless payout_amount.positive?

    safely do
      payout = Stripe::Payout.create(
        {
          amount: payout_amount.cents,
          currency: currency.to_s,
          description: pays_for.to_s,
          source_type: pay_method.model_name.element,
          statement_descriptor: "Payment #{id}",
          metadata: payment_metadata,
        },
        idempotency_key: "#{pays_for.idempotency_key}-payout-of-#{payout_amount.cents}",
      )

      if payout.status == "failed"
        raise "Payout of #{payout_amount.format} failed with '#{payout.failure_message}' (#{payout.failure_code})"
      else
        record_lw_payout!(payout)
      end
    end
  end

  def self.record_payout(payout)
    Stripe::BalanceTransaction.list(
      {
        payout: payout.id,
        type: "payment",
        expand: ["data.source.source_transfer"],
      },
      stripe_account: payout.destination.account,
    ).each do |baltxn|
      stripe_id = baltxn.source.source_transfer.source_transaction
      payment = find_by(stripe_id: stripe_id)
      raise "Cannot find payment with stripe_id #{stripe_id}" if payment.blank?

      payment.record_payout!(payout)
    end
  end

  def record_payout!(payout)
    DoubleEntry.transfer(
      freelancer_amount,
      code: :payout,
      detail: self,
      from: freelancer.account_disbursement,
      to: freelancer.account_bank,
      metadata: {
        amount: payout.amount,
        arrival_date: Time.zone.at(payout.arrival_date),
        automatic: payout.automatic,
        balance_transaction_id: payout.balance_transaction,
        destination_id: payout.destination.id,
        payout_id: payout.id,
        statement_descriptor: payout.statement_descriptor,
      },
    )
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
        metadata: payment_metadata,
        source_transaction: stripe_id,
      },
      idempotency_key: "#{pays_for.idempotency_key}-transfer-of-#{freelancer_amount.cents}",
    )
    true
  end

  def send_disbursement_emails
    mailer = milestone? ? :milestone_paid : :retainer_disbursed
    ClientMailer.with(recipient: client.primary_contact, payment: self).send(mailer).deliver_later
    FreelancerMailer.with(recipient: freelancer, payment: self).send(mailer).deliver_later
  end

  def send_deposit_emails
    mailer = milestone? ? :milestone_deposited : :retainer_deposited
    ClientMailer.with(recipient: client.primary_contact, payment: self).send(mailer).deliver_later
    FreelancerMailer.with(recipient: freelancer, payment: self).send(mailer).deliver_later
  end

private

  def payment_metadata
    pays_for.stripe_metadata.merge({
      'Payment ID': id,
    })
  end

  def process_refund!(freelancer_refund_cents, client_refund_cents = amount_cents_was)
    return false if stripe_id.blank?

    stripe_refund = Stripe::Refund.create({
      amount: client_refund_cents,
      charge: stripe_id,
      metadata: payment_metadata,
      reason: :requested_by_customer,
    }, idempotency_key: "refund-#{client_refund_cents}-of-payment-#{id}")

    record_job_args = {
      payment: self,
      client_refund_cents: stripe_refund.amount,
      metadata: {refund_id: stripe_refund.id},
    }

    # Has payment been disbursed? Withdraw freelancer refund portion from their account.
    if (transfer_id = disbursement_line&.metadata&.dig("transfer_id"))
      platform_refund_cents = Money.new(platform_fee(amount: freelancer_refund_cents), currency).cents
      reversal_amount_cents = freelancer_refund_cents - platform_refund_cents
      reversal = Stripe::Transfer.create_reversal(transfer_id,
                                                  {amount: reversal_amount_cents,
                                                   metadata: payment_metadata.merge({
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

  def record_lw_payout!(payout)
    DoubleEntry.transfer(
      payout_amount,
      code: :lw_payout,
      detail: self,
      from: ACCOUNT_FEES,
      to: ACCOUNT_BANK,
      metadata: {
        payout_id: payout.id,
        balance_transaction_id: payout.balance_transaction,
        destination_id: payout.destination,
      },
    )
  end

  def record_stripe_fees!
    DoubleEntry.transfer(
      stripe_fee,
      code: :stripe_processing,
      detail: self,
      from: ACCOUNT_FEES,
      to: ACCOUNT_STRIPE_FEES,
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

      processing_refund = client_refund - freelancer_refund - platform_refund
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
