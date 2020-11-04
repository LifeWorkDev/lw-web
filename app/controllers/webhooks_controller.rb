class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def plaid
    webhook.event = "#{webhook.data["webhook_type"]}.#{webhook.data["webhook_code"]}".downcase
    webhook.save! unless webhook.event == "item.webhook_update_acknowledged"
    head :ok
  end

  def stripe
    process_stripe("STRIPE_WEBHOOK_SECRET")
  end

  def stripe_connect
    process_stripe("STRIPE_CONNECT_WEBHOOK_SECRET")
  end

private

  # Adapted from https://plaid.com/docs/api/webhook-verification/#example-implementation
  def process_plaid
    decoded_token = JWT.decode(webhook.headers["plaid-verification"], nil, false)
    key_id = decoded_token[1]["kid"]
    key = PLAID_CLIENT.webhooks.get_verification_key(key_id)["key"]
    return false unless key["expired_at"].nil?
    # Validate the signature
    begin
      return false unless JOSE::JWT.verify(key, signed_jwt)[0]
    rescue => e
      report_error(e)
      head :bad_request && return
    end
    # Compare hashes
    body_hash = Digest::SHA256.hexdigest(request_data)
    claimed_body_hash = decoded_token[0]["request_body_sha256"]
    head :bad_request && return unless ActiveSupport::SecurityUtils.secure_compare(body_hash, claimed_body_hash)
    # Validate that token is not expired
    iat = decoded_token[0]["iat"]
    head :bad_request && return if Time.current.to_i - iat > 60 * 5
  end

  def process_stripe(secret_key)
    Stripe::Webhook::Signature.verify_header(
      request_data,
      request_headers["HTTP_STRIPE_SIGNATURE"],
      ENV[secret_key],
    )

    webhook.event = webhook.data["type"]
    webhook.save!
    head :ok
  rescue JSON::ParserError, Stripe::SignatureVerificationError => e
    report_error(e)
    head :bad_request && return
  end

  def report_error(e)
    logger.error e.inspect
    Errbase.report(e, {headers: request_headers, data: request_data})
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
