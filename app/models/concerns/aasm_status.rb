module AasmStatus
  extend ActiveSupport::Concern

  included do
    include AASM

    validates :status, presence: true

    # Transactions have to be disabled to allow DoubleEntry's transaction to be the outermost one, as some state transitions write accounting records
    aasm column: :status, use_transactions: false, whiny_transitions: false, whiny_persistence: true
  end
end
