class Org < ApplicationRecord
  include Status
  extend FriendlyId
  friendly_id :display_name

  attr_accessor :current_user

  has_many :pay_methods, dependent: :destroy
  has_many :projects, dependent: :destroy, inverse_of: :client
  accepts_nested_attributes_for :projects
  has_many :users, dependent: :nullify
  accepts_nested_attributes_for :users, reject_if: :existing_user

  jsonb_accessor :metadata,
                 work_category: [:string, array: true, default: []],
                 work_frequency: :string

  def display_name
    self[:name].presence || primary_contact&.name
  end

  def primary_contact
    users.first
  end

  def primary_pay_method
    pay_methods.first
  end

  memoize def stripe_obj
    Stripe::Customer.retrieve(stripe_id)
  end

private

  def existing_user(user_attrs)
    # Try to find existing user
    user = User.find_by(email: user_attrs[:email])
    # If user isn't found, invite user
    user ||= User.invite!(user_attrs, current_user)
    users << user # Add user to Org
    true # Prevent nested_attributes from creating user on its own
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end
end
