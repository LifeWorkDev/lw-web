module Payments::Status
  extend ActiveSupport::Concern

  included do
    include AasmStatus

    aasm do
      state :scheduled, initial: true
      state :pending
      state :succeeded
      state :disbursed
      state :failed

      event :fail do
        before do |note|
          self.note = note
        end

        transitions to: :failed
      end

      event :succeed do
        transitions from: :pending, to: :succeeded
      end

      event :disburse do
        transitions from: :succeeded, to: :disbursed do
          guard do
            transfer!
          end
        end
      end
    end

    memoize def status_class
      if scheduled? then :secondary
      elsif pending? then :warning
      elsif succeeded? then :info
      elsif disbursed? then :success
      elsif failed? then :danger
      end
    end
  end
end
