class Project < ApplicationRecord
  include Status
  extend FriendlyId
  friendly_id :name, use: :scoped, scope: :user_id

  belongs_to :org
  belongs_to :user

  monetize :amount_cents, with_model_currency: :currency, allow_nil: true, numericality: { greater_than_or_equal_to: 0 }
end
