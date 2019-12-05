class Project < ApplicationRecord
  has_logidze
  include Projects::Status
  extend FriendlyId
  friendly_id :name, use: :scoped, scope: :user_id

  belongs_to :client, class_name: 'Org', foreign_key: :org_id, inverse_of: :projects
  belongs_to :freelancer, class_name: 'User', foreign_key: :user_id, inverse_of: :projects

  monetize :amount_cents, with_model_currency: :currency, allow_nil: true, numericality: { greater_than_or_equal_to: 0 }

  scope :milestone, -> { where(type: 'MilestoneProject') }
  scope :pending, -> { where(status: PENDING_STATES) }
  scope :not_pending, -> { where.not(status: PENDING_STATES) }

  def amount_with_fee
    amount * (1 + LIFEWORK_FEE)
  end

  def milestones_changed?
    milestones.any? do |m|
      m.nilify_blanks # So that change from nil to '' isn't considered changed?
      m.new_record? || m.marked_for_destruction? || m.changed?
    end
  end

  def to_s
    name
  end

private

  def should_generate_new_friendly_id?
    name_changed? || super
  end
end
