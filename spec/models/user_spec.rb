require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { Fabricate(:user) }

  describe '.invite' do
    it 'does not send invitation email' do
      expect do
        User.invite!(Fabricate.attributes_for(:user))
      end.to change { User.count }.by(1) &
             not_enqueue_job(ActionMailer::MailDeliveryJob)
    end
  end

  describe '#reminder_time' do
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
