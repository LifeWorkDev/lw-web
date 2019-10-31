Fabricator(:user) do
  name { Faker::Name.name }
  email { Faker::Internet.email }
  password { Devise.friendly_token[0, 20] }
end

Fabricator(:admin, from: :user) do
  status :active
  roles [User::Role::ADMIN]
end

Fabricator(:client, from: :user) do
  org(fabricator: :named_org)
end

Fabricator(:freelancer, from: :user) do
  projects(count: 1, fabricator: :milestone_project)
end
