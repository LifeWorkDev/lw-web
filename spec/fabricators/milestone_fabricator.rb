require_relative "helpers"

Fabricator(:milestone) do
  date { Faker::Date.between(from: 10.days.ago, to: 30.days.from_now) }
  amount_cents { random_amount_cents }
  description { Faker::Company.catch_phrase }

  after_build do |milestone|
    milestone.project ||= Fabricate.build(:active_milestone_project, amount_cents: milestone.amount_cents, count: 0)
  end
end

Fabricator(:milestone_with_comments, from: :milestone) do
  comments(rand: 1..5)
end

Fabricator(:milestone_with_payment, from: :milestone) do
  payments(count: 1, fabricator: :succeeded_payment)
end
