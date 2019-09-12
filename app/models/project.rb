class Project < ApplicationRecord
  include Status
  extend FriendlyId
  friendly_id :name, use: :scoped, scope: :user_id

  belongs_to :client, class_name: 'Org', foreign_key: :org_id, inverse_of: :projects
  belongs_to :freelancer, class_name: 'User', foreign_key: :user_id, inverse_of: :projects

  monetize :amount_cents, with_model_currency: :currency, allow_nil: true, numericality: { greater_than_or_equal_to: 0 }

  scope :milestone, -> { where(type: 'MilestoneProject') }

  aasm do
    event :activate do
      transitions from: :pending, to: :active

      after do
        user = client.primary_contact
        user.invite! unless user.active? # Generate new invitation token
        ClientMailer.invite(user: user, project: self).deliver_now
      end
    end
  end

  def milestones_changed?
    milestones.any? do |m|
      m.nilify_blanks # So that change from nil to '' isn't considered changed?
      m.new_record? || m.marked_for_destruction? || m.changed?
    end
  end

private

  def should_generate_new_friendly_id?
    name_changed? || super
  end
end
