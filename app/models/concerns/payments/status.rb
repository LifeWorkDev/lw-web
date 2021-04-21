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
          after do
            transfer!
            payout!
          end
        end
      end

      event :partially_refund do
        transitions from: %i[pending succeeded partially_refunded], to: :partially_refunded do
          after do |client_refund_cents, freelancer_refund_cents|
            process_refund!(freelancer_refund_cents, client_refund_cents)
          end
        end
      end

      event :refund do
        transitions from: %i[pending succeeded disbursed partially_refunded], to: :refunded do
          after do |freelancer_refund_cents|
            process_refund!(freelancer_refund_cents)
          end
        end
      end
    end

    scope :paid, -> { where(status: %i[pending succeeded disbursed partially_refunded]) }
    scope :successful, -> { where(status: %i[pending succeeded disbursed partially_refunded refunded]) }

    def paid?
      pending? || succeeded? || disbursed? || partially_refunded?
    end

    def successful?
      paid? || refunded?
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
