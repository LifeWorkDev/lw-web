Fabricator(:org) do
end

Fabricator(:named_org, from: :org) do
  name { Faker::Company.name }
end

Fabricator(:org_with_users, from: :org) do
  transient count: 1
  users do |transients|
    Array.new(transients[:count]) { Fabricate(:user) }
  end
end

Fabricator(:named_org_with_users, from: :org_with_users) do
  name { Faker::Company.name }
end
