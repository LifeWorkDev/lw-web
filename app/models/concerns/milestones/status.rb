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
        transitions from: :pending, to: :deposited

        after do
          charge!
          project.activate!
          client.activate!
          send_deposit_emails
          schedule_approaching_emails
          schedule_payment
        end
      end

      event :pay do
        transitions from: :deposited, to: :paid

        after do
          transfer!
          send_payment_emails

          return unless (next_milestone = self.next)

          next_milestone.schedule_deposit
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
