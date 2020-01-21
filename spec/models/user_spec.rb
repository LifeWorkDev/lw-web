require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { Fabricate(:user) }

  describe '.invite' do
    it 'does not send invitation email' do
      expect do
        User.invite!(Fabricate.attributes_for(:user))
      end.to change { User.count }.by(1) &
             not_enqueue_mail
    end
  end

  describe '#max_pending_project_status' do
    it 'is nil with no projects' do
      expect(user.max_pending_project_status).to be_nil
    end

    context 'when a freelancer with projects' do
      let(:user) { Fabricate(:freelancer) }

      it 'is pending even with projects in a non-pending status' do
        Fabricate(:milestone_project, freelancer: user, status: :active)
        expect(user.max_pending_project_status).to eq Project.aasm.initial_state.to_s
      end

      it 'is farthest pending status' do
        Fabricate(:milestone_project, freelancer: user, status: :contract_sent)
        Fabricate(:milestone_project, freelancer: user, status: :proposal_sent)
        expect(user.max_pending_project_status).to eq 'contract_sent'
      end
    end
  end

  describe '#reminder_time' do
    let(:user) { Fabricate(:active_user) }

    it 'handles a user with a time_zone' do
      time = user.reminder_time(Date.current)
      expect(time).to be_a ActiveSupport::TimeWithZone
      expect(time.time_zone.name).to eq user.time_zone
    end

    it 'handles a user without a time_zone' do
      user = Fabricate.build(:user, time_zone: nil)
      time = user.reminder_time(Date.current)
      expect(time).to be_a ActiveSupport::TimeWithZone
      expect(time.time_zone.name).to eq 'Pacific Time (US & Canada)'
    end
  end
end
