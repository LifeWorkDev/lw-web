Fabricator(:user) do
  name { Faker::Name.name }
  email { Faker::Internet.email }
  password { Devise.friendly_token[0, 20] }
end

Fabricator(:admin_user, from: :user) do
  status :active
  roles [User::Role::ADMIN]
end

Fabricator(:client_user, from: :user) do
  org
end

Fabricator(:freelancer_user, from: :user) do
  projects(count: 1)
end
