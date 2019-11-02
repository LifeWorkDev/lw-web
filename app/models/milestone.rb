class Milestone < ApplicationRecord
  include AASM

  belongs_to :project, class_name: 'MilestoneProject'
  has_many :comments, -> { order(:created_at) }, as: :commentable, inverse_of: :commentable, dependent: :destroy

  delegate :currency, to: :project
  monetize :amount_cents, with_model_currency: :currency, allow_nil: true, numericality: { greater_than_or_equal_to: 0 }

  aasm column: :status, whiny_transitions: false, whiny_persistence: true do
    state :active, initial: true
    state :paid
    state :rejected
  end

  def amount_with_fee
    amount * (1 + LIFEWORK_FEE)
  end

  def as_json(*)
    {
      id: id,
      amount: amount&.to_f,
      date: formatted_date,
      description: description,
    }
  end

  def formatted_date
    date && I18n.l(date)
  end

  def next
    project.milestones.active.where.not(id: id).first
  end

  def percent
    (amount || 0.to_money) / (project.amount || 0.to_money)
  end

  def to_s
    "#{description} (#{formatted_date})"
  end
end
