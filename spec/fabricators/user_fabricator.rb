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
  transient project_type: Project.short_types.sample

  projects(count: 1) { |attrs| Fabricate("#{attrs[:project_type]}_project") }
end

Fabricator(:active_freelancer, from: :active_user) do
  transient project_type: Project.short_types.sample

  projects(count: 1) { |attrs| Fabricate("active_#{attrs[:project_type]}_project") }
  stripe_id { Stripe::Account.create(type: :custom).id }
end
