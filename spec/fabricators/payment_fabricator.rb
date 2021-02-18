require_relative "helpers"

Fabricator(:payment) do
  amount_cents { random_amount_cents }
  platform_fee_cents { random_fee_cents }
  processing_fee_cents { random_fee_cents }
  pay_method(fabricator: %i[bank_account_pay_method card_pay_method].sample)

  after_build do |payment|
    payment.user ||= payment.pay_method.org.primary_contact || Fabricate.build(:user)
    unless payment.pays_for.present?
      pays_for = Fabricate.build("active_#{%w[milestone retainer].sample}_project")
      payment.pays_for = pays_for.milestone? ? pays_for.milestones.first : pays_for
    end
  end
end

Fabricator(:stripe_payment, from: :payment) do
  stripe_id { Faker::Crypto.md5 }
end

Fabricator(:pending_payment, from: :stripe_payment) do
  status :pending
end

Fabricator(:succeeded_payment, from: :stripe_payment) do
  status :succeeded
end

Fabricator(:disbursed_payment, from: :stripe_payment) do
  status :disbursed
end
