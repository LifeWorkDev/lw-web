Fabricator(:milestone_project) do
  name { Faker::Commerce.product_name }
  client(fabricator: :named_org_with_users)
  freelancer(fabricator: :user)
end

Fabricator(:milestone_project_with_milestones, from: :milestone_project) do
  after_build do |project, transients|
    milestones_count = transients[:count] || rand(3..7)
    dates = (10.days.ago.to_date..30.days.from_now.to_date).to_a.sample(milestones_count)
    dates.each do |date|
      milestone = Fabricate.build(:milestone, date: date, project: project)
      project.milestones << milestone
    end
    project.amount ||= project.milestones.sum { |m| m.amount || 0 }
  end
end
