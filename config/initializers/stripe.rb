Stripe.api_key = Rails.application.credentials.stripe[:secret_key]
Stripe.client_id = Rails.application.credentials.stripe[:client_id]
Stripe.max_network_retries = 2
Stripe.log_level = Stripe::LEVEL_INFO if Rails.env.development?
