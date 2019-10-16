Stripe.api_key = Rails.application.credentials.stripe[:secret_key]
Stripe.client_id = Rails.application.credentials.stripe[:client_id]
Stripe.max_network_retries = 2
Stripe.log_level = Stripe::LEVEL_INFO if Rails.env.development?
ACH_MAX ||= Money.new(2_000_00)
ACH_MAX_BEFORE_FEE ||= ACH_MAX * 0.98
