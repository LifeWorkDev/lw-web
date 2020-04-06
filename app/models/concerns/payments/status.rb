module Payments::Status
  extend ActiveSupport::Concern

  included do
    include AasmStatus

    aasm do
      state :scheduled, initial: true
      state :pending
      state :succeeded
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
    end

    memoize def status_class
      if scheduled? then :info
      elsif pending? then :warning
      elsif succeeded? then :success
      elsif failed? then :danger
      end
    end
  end
end
