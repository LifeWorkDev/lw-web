class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    process_stripe(:webhook_secret)
  end

  def stripe_connect
    process_stripe(:connect_webhook_secret)
  end

private

  def process_stripe(secret_key)
    Stripe::Webhook::Signature.verify_header(
      request_data,
      request_headers["HTTP_STRIPE_SIGNATURE"],
      Rails.application.credentials.stripe[secret_key],
    )

    webhook.event = webhook.data["type"]
    webhook.save!
    head :ok
  rescue JSON::ParserError, Stripe::SignatureVerificationError => e
    logger.error e.inspect
    Errbase.report(e, {headers: request_headers, data: request_data})
    head :bad_request && return
  end

  def request_data
    @request_data ||= request.body.read
  end

  def request_headers
    @request_headers ||= request.headers.to_h.select { |k, _v| k =~ /^HTTP_/ }
  end

  def webhook
    @webhook ||= Webhook.new(
      source: params[:action],
      headers: request_headers,
      data: JSON.parse(request_data),
    )
  end
end
