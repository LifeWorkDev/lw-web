Fabricator(:user) do
  name { Faker::Name.name }
  email { Faker::Internet.safe_email }
end

Fabricator(:active_user, from: :user) do
  status :active
  time_zone { ActiveSupport::TimeZone.all.sample.name }
end

Fabricator(:admin, from: :active_user) do
  roles [User::Role::ADMIN]
end

Fabricator(:client, from: :user) do
  org(fabricator: :named_org)
end

Fabricator(:active_client, from: :active_user) do
  org(fabricator: :named_org)
end

Fabricator(:freelancer, from: :active_user) do
  projects(count: 1, fabricator: :milestone_project)
end

Fabricator(:active_freelancer, from: :active_user) do
  projects(count: 1, fabricator: :active_milestone_project)
  stripe_id { Stripe::Account.create(type: :custom).id }
end
