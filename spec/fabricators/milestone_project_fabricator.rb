Fabricator(:milestone_project) do
  name { Faker::Commerce.product_name }
  client(fabricator: :named_org)
  freelancer(fabricator: :user)
end

Fabricator(:milestone_project_with_milestones, from: :milestone_project) do
  milestones(fabricator: :milestone_with_comments, rand: 3..7)

  after_build do |project|
    project.amount ||= project.milestones.sum { |m| m.amount || 0 }
  end
end
