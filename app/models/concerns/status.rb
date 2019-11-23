module Status
  extend ActiveSupport::Concern

  included do
    include AASM

    validates :status, presence: true

    aasm column: :status, whiny_transitions: false, whiny_persistence: true do
      state :pending, initial: true
      state :active
      state :disabled

      event :activate do
        transitions from: :pending, to: :active
      end

      event :disable do
        transitions from: %i[pending active], to: :disabled
      end

      event :enable do
        transitions from: :disabled, to: :active
      end
    end
  end
end
