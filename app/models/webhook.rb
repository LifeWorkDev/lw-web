class Webhook < ApplicationRecord
  include AasmStatus

  after_create_commit -> { ProcessWebhook.perform_later(self) }

  aasm do
    state :received, initial: true
    state :processed

    event :process do
      transitions from: :received, to: :processed
    end
  end

  def process!
    case source
    when 'stripe'
      case event
      when 'charge.succeeded'
        payment_id = data.dig('data', 'object', 'id')
        return unless payment_id.start_with? 'py_' # ACH payments only

        Payment.find(payment_id).succeed!
      else
        raise "No handler for Stripe event #{event}"
      end
    end
  end
end
