class Org < ApplicationRecord
  include Status
  extend FriendlyId
  friendly_id :name

  attr_accessor :current_user

  has_many :projects, dependent: :destroy
  accepts_nested_attributes_for :projects
  has_many :users, dependent: :nullify
  accepts_nested_attributes_for :users, reject_if: :existing_user

private

  def existing_user(user_attrs)
    # Try to find existing user
    user = User.find_by(email: user_attrs[:email])
    # If user isn't found, invite user
    user ||= User.invite!(user_attrs, current_user)
    users << user # Add user to Org
    true # Prevent nested_attributes from creating user on its own
  end
end
