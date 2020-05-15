class Payment < ApplicationRecord
  include Payments::Status

  monetize :amount_cents, with_model_currency: :currency, numericality: {greater_than: 0}
  monetize :stripe_fee_cents, numericality: {greater_than_or_equal_to: 0}

  belongs_to :pays_for, polymorphic: true
  belongs_to :pay_method
  belongs_to :user, optional: true

  delegate :client, :freelancer, :platform_fee, :processing_fee, to: :pays_for

  scope :pending_or_succeeded, -> { where(status: %i[pending succeeded]) }

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
    Errbase.report(e, {payment: self})
    false
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

  def refund!
    return if stripe_id.blank?

    Payments::RefundJob.perform_later(stripe_id)
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
    raise "Payment #{id} must be in 'succeeded' state to transfer" unless succeeded?

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
    DoubleEntry.lock_accounts(freelancer.account_receivable, freelancer.account_disbursement, ACCOUNT_FEES) do
      DoubleEntry.transfer(
        transfer_amount,
        code: :disbursement,
        detail: self,
        from: freelancer.account_receivable,
        to: freelancer.account_disbursement,
        metadata: {transfer_id: transfer.id},
      )

      DoubleEntry.transfer(
        platform_fee,
        code: :platform,
        detail: self,
        from: freelancer.account_receivable,
        to: ACCOUNT_FEES,
        metadata: {transfer_id: transfer.id},
      )

      if processing_fee.positive?
        DoubleEntry.transfer(
          processing_fee,
          code: :processing,
          detail: self,
          from: freelancer.account_receivable,
          to: ACCOUNT_FEES,
          metadata: {transfer_id: transfer.id},
        )
      end
    end
  end

private

  def transfer_amount
    pays_for.freelancer_amount
  end
end
