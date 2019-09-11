require 'rails_helper'

RSpec.describe MilestoneProject, type: :model do
  subject(:project) { Fabricate(:milestone_project) }

  it 'fabricates' do
    expect(project.name).to be_present
  end
end
