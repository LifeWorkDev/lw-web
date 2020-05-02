class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    stripe_event = Stripe::Webhook.construct_event(
      request_data,
      request_headers['HTTP_STRIPE_SIGNATURE'],
      Rails.application.credentials.stripe[:webhook_secret],
    )

    webhook.data = stripe_event.to_h
    webhook.event = stripe_event.type
    webhook.save!

    head :ok
  rescue JSON::ParserError, Stripe::SignatureVerificationError => e
    logger.error e.inspect
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
    )
  end
end
