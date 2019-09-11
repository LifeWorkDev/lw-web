require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { Fabricate(:user) }

  it 'fabricates' do
    expect(user.name).to be_present
  end
end
