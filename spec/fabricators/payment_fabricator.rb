require_relative "helpers"

Fabricator(:payment) do
  after_build do |payment|
    if payment.pays_for.blank?
      project = Fabricate.build("active_#{%w[milestone retainer].sample}_project")
      payment.pays_for = project.milestone? ? project.milestones.first : project
    end
    project ||= payment.project
    payment.pay_method ||= project.client.primary_pay_method
    payment.amount = pays_for.client_amount(pay_method: payment.pay_method) unless payment.amount.positive?
    payment.platform_fee = payment.pays_for.platform_fee unless payment.platform_fee.positive?
    payment.processing_fee = payment.pays_for.processing_fee(pay_method: payment.pay_method) unless payment.processing_fee.positive?
    payment.paid_by ||= payment.pay_method.org.primary_contact || Fabricate.build(:user)
    payment.recipient ||= payment.freelancer || Fabricate.build(:user)
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
