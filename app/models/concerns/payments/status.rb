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
      state :partially_refunded
      state :refunded

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
        transitions from: %i[pending succeeded partially_refunded], to: :disbursed do
          guard do
            transfer!
          end
        end
      end

      event :partially_refund do
        transitions from: %i[pending succeeded partially_refunded], to: :partially_refunded do
          guard do |refund_amount_cents|
            process_refund!(refund_amount_cents)
          end
        end
      end

      event :refund do
        transitions from: %i[pending succeeded partially_refunded], to: :refunded do
          guard do
            process_refund!
          end
        end
      end
    end

    scope :successful, -> { where(status: %i[pending succeeded disbursed partially_refunded refunded]) }

    def deposited?
      succeeded? || partially_refunded?
    end

    def successful?
      pending || deposited? || disbursed? || refunded?
    end

    memoize def status_class
      if scheduled? then :secondary
      elsif pending? then :info
      elsif succeeded? then :success
      elsif disbursed? then :primary
      elsif failed? then :danger
      elsif partially_refunded? then :light
      elsif refunded? then :dark
      end
    end
  end
end
