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

  delegate :client, :freelancer, :platform_fee, :processing_fee, to: :pays_for

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

  def process_refund!(refund_amount = amount)
    return false unless stripe_id.present?

    # Can add reverse_transfer: true to support refunding disbursed payments, but need to add additional accounting lines
    stripe_refund = Stripe::Refund.create({
      amount: refund_amount.cents, charge: stripe_id
    }, idempotency_key: "refund-#{refund_amount.cents}-of-payment-#{id}")
    record_refund!(stripe_refund)
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

  def record_refund!(refund)
    DoubleEntry.transfer(
      Money.new(refund.amount),
      code: :refund,
      detail: self,
      from: freelancer.account_receivable,
      to: client.account_cash,
      metadata: {refund_id: refund.id},
    )
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

  def update_disbursement_metadata!
    return false unless disbursement_line.present?

    lines.where(code: :disbursement).update_all(metadata: transfer_metadata(disbursement_line.stripe_obj)) # rubocop:disable Rails/SkipsModelValidations
  end

private

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
