require 'rails_helper'

RSpec.describe Milestone, type: :model do
  subject(:milestone) { Fabricate(:milestone) }

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

  describe 'state machine' do
    subject(:milestone) { project.milestones.sample }

    let(:client) { project.client }
    let(:freelancer) { Fabricate(:active_freelancer) }
    let(:pay_method) { client.primary_pay_method }
    let(:project) { freelancer.projects.first }

    describe '#deposit!' do
      it "charges client's primary pay method, activates client, activates project, emails freelancer" do
        allow(FreelancerMailer).to receive(:milestone_deposited).with(user: freelancer, milestone: milestone).and_call_original
        milestone.deposit!
        expect(FreelancerMailer).to have_received(:milestone_deposited).once
        expect(project.reload.active?).to be true
        expect(client.reload.active?).to be true
      end
    end

    describe '#pay!' do
      it 'creates Stripe transfers' do
        milestone.update(status: :deposited)
        allow(Stripe::Transfer).to receive(:create).and_call_original
        milestone.pay!
        expect(Stripe::Transfer).to have_received(:create).once
      end
    end
  end
end
