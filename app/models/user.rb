class User < ApplicationRecord
  include AASM
  include Users::Roles

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

  belongs_to :organization, optional: true
  has_many :projects, dependent: :destroy
  has_many :clients, through: :projects, class_name: 'Organization'

  devise :database_authenticatable, :lockable,
         :invitable, :registerable, :recoverable, :rememberable,
         :timeoutable, :trackable, :validatable

  jsonb_accessor :metadata,
                 work_category: [:string, array: true, default: []],
                 work_type: :string

private

  def after_confirmation
    user.activate! unless user.active?
  end
end
