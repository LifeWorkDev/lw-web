class PayMethods::BankAccount < PayMethod
  attr_accessor :plaid_link_token, :plaid_account_id

  validates :name, :issuer, :kind, :plaid_id, :plaid_token, presence: true

  before_validation :exchange_plaid_link_token, on: :create

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
      org.stripe_obj.sources.create(source: stripe_token)
    else
      customer = Stripe::Customer.create(
        source: stripe_token,
        email: org.primary_contact&.email,
        name: org.display_name,
        metadata: {
          'Org ID': org.id,
        },
      )
      self.stripe_id = customer.default_source
      org.update_columns(stripe_id: customer.id) # rubocop:disable Rails/SkipsModelValidations
    end
  end
end
