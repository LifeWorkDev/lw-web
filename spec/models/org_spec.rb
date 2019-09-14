require 'rails_helper'

RSpec.describe Org, type: :model do
  subject(:org) { Fabricate(:org_with_users) }

  it 'fabricates' do
    expect(org.name).to be_nil
    expect(org.display_name).to eq(org.primary_contact.name)
  end

  describe 'accepts_nested_attributes_for :users' do
    it 'does not send invitation email when inviting a user' do
      attrs = Fabricate.attributes_for(:org).merge(users_attributes: [Fabricate.attributes_for(:user)])
      expect do
        Org.create!(attrs)
      end.to change { User.count }.by(1) &
             not_enqueue_job(ActionMailer::MailDeliveryJob)
    end
  end
end
