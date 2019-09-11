require 'rails_helper'

RSpec.describe Milestone, type: :model do
  subject(:milestone) { Fabricate(:milestone) }

  it 'fabricates' do
    expect(milestone.date).to be_present
  end
end
