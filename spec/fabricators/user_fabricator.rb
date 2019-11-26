Fabricator(:user) do
  name { Faker::Name.name }
  email { Faker::Internet.safe_email }
  password { Devise.friendly_token[0, 20] }
  time_zone { ActiveSupport::TimeZone.all.sample.name }
end

Fabricator(:active_user, from: :user) do
  status :active
end

Fabricator(:admin, from: :active_user) do
  roles [User::Role::ADMIN]
end

Fabricator(:client, from: :user) do
  org(fabricator: :named_org)
end

Fabricator(:freelancer, from: :active_user) do
  projects(count: 1, fabricator: :milestone_project)
end

Fabricator(:freelancer_with_active_project, from: :active_user) do
  projects(count: 1, fabricator: :active_milestone_project)
end
