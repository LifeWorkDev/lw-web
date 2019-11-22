class Milestone < ApplicationRecord
  has_logidze
  include AASM

  belongs_to :project, class_name: 'MilestoneProject'
  has_one :client, through: :project
  has_one :freelancer, through: :project
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

  # 3 business days before Milestone date
  memoize def reminder_date
    Business::Calendar.load_cached('achus').subtract_business_days(date, 3)
  end

  # 9am local time
  def reminder_time(user)
    user.reminder_time(reminder_date).change(hour: 9)
  end

  memoize def client_reminder_time
    reminder_time(client.primary_contact)
  end

  memoize def freelancer_reminder_time
    reminder_time(freelancer)
  end

  def to_s
    "#{description} (#{formatted_date})"
  end
end
