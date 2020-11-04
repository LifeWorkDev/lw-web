PLAID_ENV ||= Rails.env.production? ? :production : :sandbox
PLAID_WEBHOOK_ENDPOINT ||= ("#{SERVER_URL}/webhooks/plaid" if Rails.env.staging? || Rails.env.production?)
PLAID_CLIENT ||= Plaid::Client.new(env: PLAID_ENV,
                                   client_id: Rails.application.credentials.plaid[:client_id],
                                   secret: Rails.application.credentials.plaid[:secret_key])
