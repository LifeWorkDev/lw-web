class RetainerProject < Project
  ICON = mdi_url('autorenew').freeze
  NAME = 'Monthly Retainer'.freeze

  FOR_SELECT = {
    name: NAME,
    icon: ICON,
    description: 'A recurring, fixed retainer payment'.freeze,
  }.freeze

  def deposit!
    client.primary_pay_method.charge!(amount: amount, idempotency_key: "retainer-#{id}", metadata: stripe_metadata)
    activate!
  end

  memoize def description
    "#{description_begin} #{amount.format} #{description_end}"
  end

  memoize def description_begin
    'A monthly retainer of'.freeze
  end

  memoize def description_end
    "starting on #{l(Date.current.end_of_month, format: :text_without_year)}, and paid on the last calendar date of every month thereafter"
  end

private

  def stripe_metadata
    { 'Retainer Project ID': id }
  end
end
