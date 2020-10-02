class Webhook < ApplicationRecord
  include AasmStatus

  after_create_commit -> { ProcessWebhook.perform_later(self) }

  aasm do
    state :received, initial: true
    state :processed

    event :process do
      transitions from: :received, to: :processed do
        after do
          case source
          when "stripe"
            case event
            when "charge.succeeded"
              payment_id = data.dig("data", "object", "id")

              if payment_id.start_with? "py_" # ACH payments only
                Payment.find_by(stripe_id: payment_id)&.succeed!
              else true; end
            else
              raise "No handler for Stripe event #{event}"
            end
          end
        end
      end
    end
  end
end
