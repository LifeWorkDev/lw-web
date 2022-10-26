module Status
  extend ActiveSupport::Concern

  included do
    include AasmStatus

    aasm do
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

    scope :not_disabled, -> { where.not(status: :disabled) }

    memoize def status_class
      pending? ? :warning : :success
    end
  end
end
