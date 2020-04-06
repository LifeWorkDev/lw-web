require 'rails_helper'

RSpec.describe RetainerProject, type: :model do
  subject(:project) { Fabricate(:retainer_project) }

  describe '#next_date' do
    it { expect(project.next_date.month).to eq project.start_date.month + 1 }
    it { expect(project.next_date.day).to eq 1 }
  end

  describe '#first_amount' do
    it 'is less than the monthly amount' do
      expect(project.first_amount).to be < project.amount
    end

    context 'when start date is beginning of the month' do
      subject(:project) { Fabricate(:retainer_project, start_date: Date.current.beginning_of_month) }

      it 'equals the full monthly amount' do
        expect(project.first_amount).to eq project.amount
      end
    end
  end
end
