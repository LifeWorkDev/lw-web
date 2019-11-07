class PayMethods::BankAccount < PayMethod
  attr_accessor :plaid_link_token, :plaid_account_id

  validates :plaid_id, :plaid_token, presence: true

  before_validation :exchange_plaid_link_token, on: :create

  def charge!(amount:, metadata: {})
    Stripe::Charge.create(
      amount: amount.cents,
      currency: amount.currency.to_s,
      customer: org.stripe_id,
      source: stripe_id,
      metadata: metadata,
    )
  end

  memoize def stripe_obj
    Stripe::Source.retrieve(stripe_id)
  end

private

  def exchange_plaid_link_token
    return if stripe_id.present?

    plaid = Plaid::Client.new(env: PLAID_ENV,
                              client_id: Rails.application.credentials.plaid[:client_id],
                              secret: Rails.application.credentials.plaid[:secret_key],
                              public_key: Rails.application.credentials.plaid[:public_key])
    response = plaid.item.public_token.exchange(plaid_link_token)
    self.plaid_id = response['item_id']
    self.plaid_token = response['access_token']
    response = plaid.processor.stripe.bank_account_token.create(plaid_token, plaid_account_id)
    stripe_token = response['stripe_bank_account_token']

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
      org.update_columns(stripe_id: customer.id) # rubocop:disable Rails/SkipsModelValidations
    end
  end
end
