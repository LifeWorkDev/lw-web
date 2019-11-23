require 'rails_helper'

RSpec.describe Org, type: :model do
  describe 'accepts_nested_attributes_for :users' do
    let(:user_attrs) { Fabricate.attributes_for(:user).except(:password) }

    context 'with existing user' do
      subject(:org) { Fabricate(:named_org) }

      let(:user) { Fabricate(:user, org: org) }
      let(:attrs) { { users_attributes: [user_attrs.merge(id: user.id)] } }

      it 'updates the user by id' do
        expect do
          org.update(attrs)
        end.to change { user.reload.name } &
               change { user.email }
      end

      it 'updates the user by email' do
        user = Fabricate(:user)
        user_attrs[:email] = user.email
        attrs = { users_attributes: [user_attrs] }
        expect do
          org.update(attrs)
        end.to change { user.reload.org_id }.to(org.id) &
               change { user.name }
      end

      it 'does not update the user when save fails' do
        expect do
          expect(org.update(attrs.merge(status: nil))).to be false
        end.to not_change { user.reload.name }
      end
    end

    context 'without existing user' do
      let(:attrs) { Fabricate.attributes_for(:named_org).merge(current_user: inviter, users_attributes: [user_attrs]) }
      let(:inviter) { Fabricate(:user) }
      let(:new_user) { User.last }

      it 'creates a user of this org, invited by current_user' do
        org = Org.new(attrs)
        expect do
          org.save
        end.to change { User.count }.by(1)
        expect(new_user.org).to eq Org.last
        expect(new_user.invited_by).to eq inviter
      end
    end
  end
end
