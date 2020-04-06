module Milestones::Status
  extend ActiveSupport::Concern

  included do
    include AasmStatus

    aasm do
      state :pending, initial: true
      state :deposited
      state :paid
      state :rejected

      event :deposit do
        transitions from: :pending, to: :deposited do
          guard do |user|
            payments.create!(amount: client_amount, pay_method: pay_method, user: user).charge!
          end
        end

        after_commit do
          send_deposit_emails
          schedule_approaching_emails if reminder_date.future?
          schedule_payment
          project.activate!
          client.activate!
        end
      end

      event :pay do
        transitions from: :deposited, to: :paid do
          guard do
            payment.transfer!
          end
        end

        after_commit do
          send_payment_emails
          self.next&.schedule_deposit
        end
      end
    end

    memoize def status_class
      if pending? then :info
      elsif deposited? then :primary
      elsif paid? then :success
      elsif rejected? then :danger
      end
    end
  end
end
