class Milestone < ApplicationRecord
  include AASM

  belongs_to :project, class_name: 'MilestoneProject'
  has_many :comments, -> { order(:created_at) }, as: :commentable, dependent: :destroy

  delegate :currency, to: :project
  monetize :amount_cents, with_model_currency: :currency, allow_nil: true, numericality: { greater_than_or_equal_to: 0 }

  aasm column: :status, whiny_transitions: false, whiny_persistence: true do
    state :active, initial: true
    state :paid
    state :rejected
  end

  def as_json(*)
    {
      id: id,
      amount: amount.to_f,
      date: formatted_date,
      description: description,
    }
  end

  def formatted_date
    date && I18n.l(date, format: :date_only)
  end

  def percent
    (amount || 0.to_money) / (project.amount || 0.to_money)
  end

  alias to_s formatted_date
end
