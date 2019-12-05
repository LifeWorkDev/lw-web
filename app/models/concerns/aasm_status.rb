module AasmStatus
  extend ActiveSupport::Concern

  included do
    include AASM

    validates :status, presence: true

    aasm column: :status, whiny_transitions: false, whiny_persistence: true
  end
end
