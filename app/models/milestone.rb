class Milestone < ApplicationRecord
  has_logidze
  include Commentable
  include Dates
  include Fees
  include Milestones::Status

  belongs_to :project, class_name: "MilestoneProject"
  has_one :client, through: :project
  has_many :client_users, through: :client, source: :users
  has_one :freelancer, through: :project
  has_many :payments, as: :pays_for, dependent: :destroy

  delegate :currency, :client_pays_fees?, :fee_percent, to: :project
  monetize :amount_cents, with_model_currency: :currency, allow_nil: true, numericality: {greater_than_or_equal_to: 10, on: :create}

  before_update :update_payment_amount, if: -> { (deposited? || paid?) && amount_cents_changed? }

  pg_search_scope :pg_search,
    against: %i[description],
    associated_against: {
      client: %i[name],
      client_users: %i[name email],
      freelancer: %i[name email],
      project: %i[name],
    }

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

  def next
    this_idx = project.milestones.index(self)
    nxt = project.milestones[this_idx + 1]
    nxt if nxt&.pending?
  end

  def latest_payment
    payments.successful.last
  end

  def percent
    (amount || 0.to_money) / (project.amount || 0.to_money)
  end

  memoize def client_approaching_text
    "At the beginning of the day on #{l(date, format: :text_without_year)} we'll release #{amount&.format} from our account to #{freelancer.name}"
  end

  def to_s
    "#{description} (#{amount_cents && "#{amount&.format} on "}#{formatted_date})"
  end

  def send_deposit_emails
    FreelancerMailer.with(recipient: freelancer, milestone: self).milestone_deposited.deliver_later
    ClientMailer.with(recipient: client.primary_contact, milestone: self).milestone_deposited.deliver_later
  end

  def send_payment_emails
    ClientMailer.with(recipient: client.primary_contact, milestone: self).milestone_paid.deliver_later
    FreelancerMailer.with(recipient: freelancer, milestone: self).milestone_paid.deliver_later
  end

  def schedule_approaching_emails
    FreelancerMailer.with(recipient: freelancer, milestone: self).milestone_approaching.deliver_later(wait_until: freelancer_reminder_time)
    ClientMailer.with(recipient: client.primary_contact, milestone: self).milestone_approaching.deliver_later(wait_until: client_reminder_time)
  end

  def schedule_deposit(schedule_for = deposit_time)
    Milestones::DepositJob.set(wait_until: schedule_for).perform_later(self) if pending?
  end

  def schedule_payment
    Milestones::PayJob.set(wait_until: payment_time).perform_later(self)
  end

  def idempotency_key
    "milestone-#{id}"
  end

  def stripe_metadata
    {'Milestone ID': id}
  end

private

  def update_payment_amount
    raise "Can't increase the amount of a #{status} milestone" if amount_cents > amount_cents_was

    latest_payment.issue_refund!(new_amount: client_amount, freelancer_refund_cents: amount_cents_was - amount_cents)
  end
end
