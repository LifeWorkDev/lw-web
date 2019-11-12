require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { Fabricate(:user) }

  it 'fabricates' do
    expect(user.name).to be_present
  end

  describe '.invite' do
    it 'does not send invitation email' do
      expect do
        User.invite!(Fabricate.attributes_for(:user))
      end.to change { User.count }.by(1) &
             not_enqueue_job(ActionMailer::MailDeliveryJob)
    end
  end
end
