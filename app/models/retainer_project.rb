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

  def deposit!(user = nil)
    activate! if payments.create!(amount: first_client_amount, pay_method: pay_method, user: user).charge!
  end

  memoize def description(for_client: false, pay_method: ' ')
    "#{t('retainer_project.description.begin')} #{(for_client ? client_amount : amount).format(no_cents_if_whole: true)} #{' will then be ' if for_client} #{t('retainer_project.description.middle', pay_method: pay_method)} #{l(next_date, format: :text_without_year)}, #{t('retainer_project.description.end')}"
  end

  memoize def first_amount
    return amount if start_date.day == 1

    days = Time.days_in_month(start_date.month, start_date.year)
    amount * (days + 1 - start_date.day).fdiv(days)
  end

  memoize def first_client_amount
    client_amount(first_amount)
  end

  memoize def first_description(for_client: false)
    "The first payment of #{(for_client ? first_client_amount : first_amount).format(no_cents_if_whole: true)} is due by #{l(start_date, format: :text_without_year)}, and will be disbursed to #{freelancer.name} on #{l(next_date, format: :text_without_year)}."
  end

  def idempotency_key
    "retainer-#{id}"
  end

  def next_date
    (start_date + 1.month).beginning_of_month
  end
  alias date next_date

  def stripe_metadata
    { 'Retainer Project ID': id }
  end
end
