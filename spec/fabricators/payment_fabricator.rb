Fabricator(:payment) do
  amount_cents { Faker::Commerce.price(range: 500..1_000) }
  pay_method(fabricator: %i[bank_account_pay_method card_pay_method].sample)

  after_build do |payment|
    payment.user ||= payment.pay_method.org.primary_contact || Fabricate.build(:user)
    pays_for = Fabricate.build("active_#{%w[milestone retainer].sample}_project")
    payment.pays_for ||= pays_for.milestone? ? pays_for.milestones.first : pays_for
  end
end

Fabricator(:pending_payment, from: :payment) do
  status :pending
end

Fabricator(:succeeded_payment, from: :payment) do
  status :succeeded
end
