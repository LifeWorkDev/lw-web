class Project < ApplicationRecord
  include Status
  extend FriendlyId
  friendly_id :name, use: :scoped, scope: :user_id

  belongs_to :org
  belongs_to :user

  monetize :amount_cents, with_model_currency: :currency, allow_nil: true, numericality: { greater_than_or_equal_to: 0 }

  def milestones_changed?
    milestones.any? do |m|
      m.nilify_blanks # So that change from nil to '' isn't considered changed?
      m.new_record? || m.marked_for_destruction? || m.changed?
    end
  end
end
