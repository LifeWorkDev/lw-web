class PayMethods::BankAccount < PayMethod
  attr_accessor :plaid_link_token

  validates :plaid_id, :plaid_token, presence: true

  before_validation :exchange_plaid_link_token, on: :create

  def bank_account?
    true
  end

  def charge!(amount:, metadata: {})
    raise "Insufficent balance for Bank Account #{id}. Attempted to charge #{amount.format} to account with balance #{balance.format}" if Rails.env.production? && balance < amount

    Stripe::Charge.create(
      amount: amount.cents,
      currency: amount.currency.to_s,
      customer: org.stripe_id,
      source: stripe_id,
      metadata: metadata,
    )
  end

  memoize def balance
    (plaid_obj.balances['available'] || plaid_obj.balances['current']).to_money(plaid_obj.balances['iso_currency_code'])
  end

  memoize def plaid_obj
    PLAID_CLIENT.accounts.balance.get(plaid_token, account_ids: [plaid_id])['accounts'].first
  end

  memoize def stripe_obj
    Stripe::Source.retrieve(stripe_id)
  end

private

  def exchange_plaid_link_token
    return if stripe_id.present?

    response = PLAID_CLIENT.item.public_token.exchange(plaid_link_token)
    self.plaid_token = response['access_token']
    response = PLAID_CLIENT.processor.stripe.bank_account_token.create(plaid_token, plaid_id)
    stripe_token = response['stripe_bank_account_token']
    PLAID_CLIENT.item.webhook.update(plaid_token, PLAID_WEBHOOK_ENDPOINT)

    if org.stripe_id.present?
      source = Stripe::Customer.create_source(org.stripe_id, source: stripe_token)
      self.stripe_id = source.id
    else
      customer = Stripe::Customer.create(
        name: org.display_name,
        email: org.primary_contact&.email,
        source: stripe_token,
        metadata: {
          'Org ID': org.id,
        },
      )
      self.stripe_id = customer.default_source
      if org.persisted?
        org.update_columns(stripe_id: customer.id) # rubocop:disable Rails/SkipsModelValidations
      else
        org.stripe_id = customer.id
      end
    end
  end
end
