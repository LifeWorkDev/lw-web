class User < ApplicationRecord
  include AASM
  include Users::Roles

  devise :database_authenticatable, :lockable,
         :invitable, :registerable, :recoverable, :rememberable,
         :timeoutable, :trackable, :validatable

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

private

  def after_confirmation
    user.activate! unless user.active?
  end
end
