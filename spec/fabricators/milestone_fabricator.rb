Fabricator(:milestone) do
  date { Faker::Date.between(from: 10.days.ago, to: 30.days.from_now) }
  amount_cents { Faker::Commerce.price(range: 500..1_000) }
  description { Faker::Company.catch_phrase }

  after_build do |milestone|
    milestone.project ||= Fabricate.build(:active_milestone_project, count: 0)
  end
end

Fabricator(:milestone_with_comments, from: :milestone) do
  comments(rand: 1..5)
end

Fabricator(:milestone_with_payment, from: :milestone) do
  payments(count: 1, fabricator: :succeeded_payment)
end
