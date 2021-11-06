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
            return false if project.inactive?
            !payments.create!(
              amount: client_amount,
              platform_fee: platform_fee,
              processing_fee: processing_fee,
              client_pays_fees: client_pays_fees?,
              pay_method: pay_method,
              scheduled_for: date,
              paid_by: user,
              recipient: freelancer,
            ).charge!.failed?
          end
        end

        after_commit do
          send_deposit_emails
          schedule_approaching_emails if reminder_date.future?
          schedule_payment
          project.activate! if project.may_activate?
        end
      end

      event :pay do
        transitions from: :deposited, to: :paid do
          after do
            latest_payment.disburse!
          end
        end

        after_commit do
          send_payment_emails
          self.next&.schedule_deposit(deposit_time)
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
