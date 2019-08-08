class Org < ApplicationRecord
  include Status
  extend FriendlyId
  friendly_id :name_or_user_name

  attr_accessor :current_user

  has_many :projects, dependent: :destroy
  accepts_nested_attributes_for :projects
  has_many :users, dependent: :nullify
  accepts_nested_attributes_for :users, reject_if: :existing_user

  def name_or_user_name
    self[:name].presence || users.first.name
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
