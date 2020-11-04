class Webhook < ApplicationRecord
  include AasmStatus

  after_create_commit -> { ProcessWebhook.perform_later(self) if may_process? }

  aasm do
    state :received, initial: true
    state :processed

    event :process do
      transitions from: :received, to: :processed do
        guard { source == "stripe" }

        after do
          case source
          when "stripe"
            case event
            when "charge.succeeded"
              payment_id = data.dig("data", "object", "id")
              payment = Payment.find_by(stripe_id: payment_id)
              raise "No payment found with stripe id #{payment_id}" if !payment && Rails.env.production?

              if payment_id.start_with? "py_" # ACH payments only
                payment&.succeed! unless payment&.disbursed?
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
