Fabricator(:pay_method) do
  created_by(fabricator: :user)
  org(fabricator: :named_org)
end

Fabricator(:bank_account_pay_method, class_name: 'pay_methods/bank_account', from: :pay_method) do
  type         PayMethods::BankAccount
  issuer       { Faker::Bank.name }
  kind         { %i[checking savings].sample }
  last_4       { Faker::Bank.account_number(digits: 4) }
  plaid_id     { Faker::Crypto.md5 }
  plaid_token  { Faker::Crypto.md5 }
  stripe_id    { StripeMock.generate_bank_token }
end

Fabricator(:card_pay_method, class_name: 'pay_methods/card', from: :pay_method) do
  type       PayMethods::Card
  issuer     { ['Visa', 'Mastercard', 'Discover', 'American Express'].sample }
  kind       { %w[credit debit prepaid unknown].sample }
  exp_month  { Faker::Stripe.month }
  exp_year   { Faker::Stripe.year }
  last_4     { Faker::Business.credit_card_number.last(4) }
  stripe_id  { StripeMock.generate_card_token }
end
