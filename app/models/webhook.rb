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
            stripe_obj = Stripe::Event.construct_from(data).data.object
            case event
            when "charge.succeeded"
              payment = Payment.find_by(stripe_id: stripe_obj.id)
              raise "No payment found with stripe id #{stripe_obj.id}" if !payment && Rails.env.production?

              if stripe_obj.id.start_with? "py_" # ACH payments only
                payment&.succeed! if payment&.may_succeed?
              else true; end
            when "payment_method.automatically_updated"
              pay_method = PayMethods::Card.find_by(stripe_id: stripe_obj.id)
              raise "No card found with stripe id #{stripe_obj.id}" if !pay_method && Rails.env.production?

              pay_method.update_from_stripe_object!(stripe_obj)
            else
              raise "No handler for Stripe event #{event}"
            end
          when "stripe_connect"
            case event
            when "payout.paid"
              Stripe::BalanceTransaction.list({payout: "po_1HF9QQEdQ2VcgcgnKRFJxHI5", limit: 100, type: "payment"}, {stripe_account: "acct_1H32LCEdQ2Vcgcgn"}).map(&:source)
            else
              raise "No handler for Stripe Connect event #{event}"
            end
          end
        end
      end
    end
  end
end
