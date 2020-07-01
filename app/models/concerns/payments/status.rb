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
        transitions from: %i[pending succeeded], to: :disbursed do
          guard do
            transfer!
          end
        end
      end

      event :refund do
        transitions from: %i[pending succeeded], to: :refunded do
          guard do
            stripe_id.present? && record_refund!(Stripe::Refund.create(charge: stripe_id)) # Can add reverse_transfer: true to support refunding disbursed payments, but need to add additional accounting lines
          end
        end
      end
    end

    memoize def status_class
      if scheduled? then :secondary
      elsif pending? then :info
      elsif succeeded? then :success
      elsif disbursed? then :primary
      elsif failed? then :danger
      elsif refunded? then :dark
      end
    end
  end
end
