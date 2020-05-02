require "rails_helper"

RSpec.describe Org, type: :model do
  it "saves with a blank name" do
    user_attributes = Fabricate.attributes_for(:user)
    expect { Org.create!(name: "", users_attributes: [user_attributes]) }.not_to raise_error
    expect(Org.last.name).to eq user_attributes[:name]
  end
end
