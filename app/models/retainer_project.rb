class RetainerProject < Project
  include Commentable
  include Dates

  has_many :payments, as: :pays_for, dependent: :destroy

  before_destroy -> { Milestone.where(project_id: id).destroy_all }

  jsonb_accessor :metadata,
    disbursement_day: :integer,
    start_date: :date

  ICON = mdi_url("autorenew").freeze
  NAME = "Monthly Retainer".freeze

  FOR_SELECT = {
    name: NAME,
    icon: ICON,
    description: "A recurring, fixed retainer payment".freeze,
  }.freeze

  aasm do
    event :activate do
      transitions from: :client_invited, to: :active

      after_commit do
        FreelancerMailer.with(recipient: freelancer, project: self).retainer_agreed.deliver_later
        Retainer::DepositJob.set(wait_until: deposit_time(start_date)).perform_later(self)
      end
    end
  end

  def deposit!(user = nil)
    return unless payments.create!(
      amount: latest_payment ? client_amount : first_client_amount,
      pay_method: pay_method,
      scheduled_for: deposit_time(latest_payment ? next_date : start_date),
      user: user,
    ).charge!

    send_deposit_emails
    schedule_disbursement
    activate!
  end

  def disburse!
    return unless latest_payment

    latest_payment.disburse!
    send_disbursement_emails
    schedule_deposit
  end

  memoize def description(for_client: false)
    "#{t("retainer_project.description.begin")} #{(for_client ? client_amount : amount).format(no_cents_if_whole: true)} #{"will then be" if for_client} #{t("retainer_project.description.middle", pay_method: for_client && pay_method ? " from your #{pay_method} " : " ")} #{l(next_date, format: :text_without_year)}, #{t("retainer_project.description.end", day: disbursement_day.ordinalize)}"
  end

  def first_amount
    return amount if start_date.day == disbursement_day

    days = Time.days_in_month(start_date.month, start_date.year)
    amount * (next_date - start_date).fdiv(days)
  end

  memoize def first_client_amount
    client_amount(first_amount)
  end

  memoize def first_description(for_client: false)
    "The first payment of #{(for_client ? first_client_amount : first_amount).format(no_cents_if_whole: true)} is due on #{l(start_date, format: :text_without_year)}, and will be disbursed to #{freelancer.name} on #{l(next_date, format: :text_without_year)}."
  end

  def for_subject
    "a new engagement".freeze
  end

  def idempotency_key
    "retainer-#{id}"
  end

  def latest_payment
    payments.successful.last
  end

  def next_date
    current_date = latest_payment&.scheduled_for&.to_date || start_date
    next_date = current_date.safe_change_day(disbursement_day)
    next_date += 1.month if next_date <= current_date
    next_date.safe_change_day(disbursement_day)
  end
  alias_method :date, :next_date

  def schedule_deposit
    return unless active?

    Retainer::DepositJob.set(wait_until: deposit_time).perform_later(self)
  end

  def schedule_disbursement
    Retainer::DisburseJob.set(wait_until: disbursement_time).perform_later(self)
  end

  def send_disbursement_emails
    ClientMailer.with(recipient: client.primary_contact, project: self).retainer_disbursed.deliver_later
    FreelancerMailer.with(recipient: freelancer, project: self).retainer_disbursed.deliver_later
  end

  def send_deposit_emails
    FreelancerMailer.with(recipient: freelancer, project: self).retainer_deposited.deliver_later
    ClientMailer.with(recipient: client.primary_contact, project: self).retainer_deposited.deliver_later
  end

  def stripe_metadata
    {'Retainer Project ID': id}
  end
end
