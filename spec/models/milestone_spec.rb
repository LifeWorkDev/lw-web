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

  describe '#reminder_date' do
    subject(:milestone) { Fabricate(:milestone, date: 1.week.from_now.beginning_of_week(:monday)) }

    it 'handles weekends correctly' do
      expect((milestone.date - milestone.reminder_date).to_i).to be >= 5
    end
  end

  describe '#reminder_time' do
    it 'sets hour to 9am' do
      expect(milestone.reminder_time(User.all.sample).hour).to eq 9
    end
  end
end
