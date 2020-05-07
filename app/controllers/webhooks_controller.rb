class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    Stripe::Webhook::Signature.verify_header(
      request_data,
      request_headers["HTTP_STRIPE_SIGNATURE"],
      Rails.application.credentials.stripe[:webhook_secret],
    )

    webhook.event = webhook.data["type"]
    webhook.save!
    head :ok
  rescue JSON::ParserError, Stripe::SignatureVerificationError => e
    logger.error e.inspect
    Errbase.report(e, {headers: request_headers, data: request_data})
    head :bad_request && return
  end

private

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
