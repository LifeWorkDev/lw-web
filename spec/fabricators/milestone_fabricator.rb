Fabricator(:milestone) do
  date { Faker::Date.between(from: 10.days.ago, to: 30.days.from_now) }
  amount_cents { rand(100_00..1_000_00) }
  description { Faker::Company.catch_phrase }

  after_build do |milestone|
    milestone.project ||= Fabricate.build(:milestone_project, milestones: [])
  end
end

Fabricator(:milestone_with_comments, from: :milestone) do
  comments(rand: 1..5)
end
