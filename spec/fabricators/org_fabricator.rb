Fabricator(:org) do
end

Fabricator(:named_org, from: :org) do
  name { Faker::Company.name }
end

Fabricator(:org_with_users, from: :org) do
  transient count: 1
  transient user_type: :user
  users do |transients|
    Array.new(transients[:count]) { Fabricate(transients[:user_type]) }
  end
end

Fabricator(:named_org_with_users, from: :org_with_users) do
  name { Faker::Company.name }
end

Fabricator(:org_with_active_users, from: :org_with_users) do
  transient user_type: :active_user
end

Fabricator(:named_org_with_active_users, from: :org_with_active_users) do
  name { Faker::Company.name }
end

Fabricator(:org_with_pay_method, from: :named_org_with_active_users) do
  pay_methods(count: 1, fabricator: %i[bank_account_pay_method card_pay_method].sample)
end
