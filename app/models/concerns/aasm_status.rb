module AasmStatus
  extend ActiveSupport::Concern

  included do
    include AASM

    validates :status, presence: true

    # Transactions have to be disabled to allow DoubleEntry's transaction to be the outermost one, as some state transitions write accounting records
    # Whiny Transitions: raise when transition is disallowed
    # Whiny Persistence: bang methods behave the same as rails bang methods (raise on failure instead of returning false)
    aasm column: :status, use_transactions: false, whiny_transitions: true, whiny_persistence: true
  end
end
