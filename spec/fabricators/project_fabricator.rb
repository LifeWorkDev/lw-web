Fabricator(:project) do
  name { Faker::Commerce.product_name }
  client(fabricator: :named_org_with_users)
  freelancer(fabricator: :user)
end

Fabricator(:active_project, from: :project) do
  status :active
  client(fabricator: :org_with_pay_method)
end

Fabricator(:milestone_project, from: :project, class_name: :milestone_project)

Fabricator(:milestone_project_with_milestones, from: :milestone_project) do
  transient :count

  after_build do |project, transients|
    milestone_count = transients[:count] || rand(3..7)
    dates = (10.days.from_now.to_date..60.days.from_now.to_date).to_a.sample(milestone_count)
    dates.each do |date|
      milestone = Fabricate.build(:milestone, date: date, project: project)
      project.milestones << milestone
    end
    project.amount ||= project.milestones.sum { |m| m.amount || 0 }
  end
end

Fabricator(:active_milestone_project, from: :milestone_project_with_milestones) do
  status :active
  client(fabricator: :org_with_pay_method)
end

Fabricator(:retainer_project, from: :project, class_name: :retainer_project) do
  amount { Faker::Commerce.price(range: 500..1_000) }
  start_date { Faker::Date.between_except(from: Date.current.beginning_of_month, to: Date.current.end_of_month, excepted: Date.current.beginning_of_month) }
end

Fabricator(:active_retainer_project, from: :active_project, class_name: :retainer_project) do
  amount { Faker::Commerce.price(range: 500..1_000) }
  start_date { Faker::Date.between_except(from: Date.current.beginning_of_month, to: Date.current.end_of_month, excepted: Date.current.beginning_of_month) }
end
