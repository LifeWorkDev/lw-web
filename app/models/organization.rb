class Organization < ApplicationRecord
  has_many :projects, dependent: :destroy
  accepts_nested_attributes_for :projects
  has_many :users, dependent: :nullify
  accepts_nested_attributes_for :users, reject_if: :existing_user

private

  def existing_user(user_attrs)
    if (user = User.find_by(email: user_attrs[:email]))
      users << user
      return true
    end
    false
  end
end
