class Milestone < ApplicationRecord
  has_logidze
  include Milestones::Status

  belongs_to :project, class_name: 'MilestoneProject'
  has_one :client, through: :project
  has_one :freelancer, through: :project
  has_many :comments, -> { order(:created_at) }, as: :commentable, inverse_of: :commentable, dependent: :destroy

  delegate :currency, to: :project
  monetize :amount_cents, with_model_currency: :currency, allow_nil: true, numericality: { greater_than_or_equal_to: 0 }

  def amount_with_fee
    amount * (1 + LIFEWORK_FEE)
  end

  def client_amount
    amount_with_fee
  end

  def freelancer_amount
    amount
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
    date && l(date)
  end

  memoize def comment_reply_address
    "comments-#{id}@#{REPLIES_HOST}"
  end

  def next
    project.milestones.pending.where.not(id: id).first
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

  memoize def client_approaching_text
    "At the end of the day on #{l(date, format: :text_without_year)} we'll release #{amount&.format} from our account to #{freelancer.name}"
  end

  def to_s
    "#{description} (#{amount_cents && "#{amount&.format} on "}#{formatted_date})"
  end

private

  def charge!
    client.primary_pay_method.charge!(amount: client_amount, metadata: stripe_metadata)
  end

  def transfer!
    Stripe::Transfer.create(
      {
        amount: freelancer_amount.cents,
        currency: currency.to_s,
        description: to_s,
        destination: freelancer.stripe_id,
        metadata: stripe_metadata,
        source_type: client.primary_pay_method.card? ? :card : :bank_account,
      },
      idempotency_key: "milestone-#{id}-transfer",
    )
  end

  def stripe_metadata
    { 'Milestone ID': id }
  end
end
