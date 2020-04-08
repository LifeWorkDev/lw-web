class RetainerProject < Project
  include Commentable
  include Dates

  has_many :payments, as: :pays_for, dependent: :destroy

  jsonb_accessor :metadata,
                 start_date: :date

  ICON = mdi_url('autorenew').freeze
  NAME = 'Monthly Retainer'.freeze

  FOR_SELECT = {
    name: NAME,
    icon: ICON,
    description: 'A recurring, fixed retainer payment'.freeze,
  }.freeze

  alias first_amount amount

  def deposit!(user = nil)
    return unless payments.create!(amount: first_client_amount, pay_method: pay_method, user: user).charge!

    send_deposit_emails
    activate!
    client.activate!
  end

  memoize def description(for_client: false)
    "#{t('retainer_project.description.begin')} #{(for_client ? client_amount : amount).format(no_cents_if_whole: true)} #{' will then be ' if for_client} #{t('retainer_project.description.middle', pay_method: for_client ? " from your #{pay_method} " : ' ')} #{l(next_date, format: :text_without_year)}, #{t('retainer_project.description.end', day: start_date.day.ordinalize)}"
  end

  memoize def first_client_amount
    client_amount(first_amount)
  end

  memoize def first_description(for_client: false)
    "The first payment of #{(for_client ? first_client_amount : first_amount).format(no_cents_if_whole: true)} is due by #{l(start_date, format: :text_without_year)}, and will be disbursed to #{freelancer.name} on #{l(next_date, format: :text_without_year)}."
  end

  def for_subject
    'a new engagement'.freeze
  end

  def idempotency_key
    "retainer-#{id}"
  end

  def next_date
    start_date + 1.month
  end
  alias date next_date

  def send_deposit_emails
    FreelancerMailer.with(recipient: freelancer, project: self).retainer_deposited.deliver_later
    ClientMailer.with(recipient: client.primary_contact, project: self).retainer_deposited.deliver_later
  end

  def stripe_metadata
    { 'Retainer Project ID': id }
  end
end
