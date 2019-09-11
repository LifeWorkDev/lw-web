require 'rails_helper'

RSpec.describe Org, type: :model do
  subject(:org) { Fabricate(:org_with_users) }

  it 'fabricates' do
    expect(org.name).to be_nil
    expect(org.display_name).to eq(org.users.first.name)
  end
end
