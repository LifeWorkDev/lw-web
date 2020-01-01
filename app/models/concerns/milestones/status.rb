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
          FreelancerMailer.milestone_deposited(user: freelancer, milestone: self).deliver_later
        end
      end

      event :pay do
        transitions from: :deposited, to: :paid

        after do
          transfer!
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
