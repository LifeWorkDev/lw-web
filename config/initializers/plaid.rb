PLAID_ENV ||= Rails.env.production? ? :production : :sandbox
PLAID_WEBHOOK_ENDPOINT ||= nil
PLAID_CLIENT ||= Plaid::Client.new(env: PLAID_ENV,
                                   client_id: Rails.application.credentials.plaid[:client_id],
                                   secret: Rails.application.credentials.plaid[:secret_key])
