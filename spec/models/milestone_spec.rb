require 'rails_helper'

RSpec.describe Milestone, type: :model do
  subject(:milestone) { Fabricate(:milestone) }

  it 'fabricates' do
    expect(milestone.date).to be_present
  end

  describe '#next' do
    subject(:milestone) { project.milestones.first }

    let(:project) { Fabricate(:milestone_project_with_milestones) }

    it 'returns the next milestone by date' do
      project.reload # Make sure milestones are loaded from the DB in correct order
      expect(milestone.next.date).to eq(project.milestones.pluck(:date).second)
    end
  end
end
