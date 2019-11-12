require 'rails_helper'

RSpec.describe Org, type: :model do
  describe 'accepts_nested_attributes_for :users' do
    let(:user_attrs) { Fabricate.attributes_for(:user).except(:password) }

    context 'with existing user' do
      subject(:org) { Fabricate(:named_org) }

      it 'works with user[:id]' do
        user = Fabricate(:user, org: org)
        attrs = { users_attributes: [user_attrs.merge(id: user.id)] }
        expect do
          org.update!(attrs)
        end.to change { user.reload.name } &
               change { user.email }
      end

      it 'works with user[:email]' do
        user = Fabricate(:user)
        user_attrs[:email] = user.email
        attrs = { users_attributes: [user_attrs] }
        expect do
          org.update!(attrs)
        end.to change { user.reload.org_id }.to(org.id) &
               change { user.name }
      end
    end

    context 'without existing user' do
      it 'creates a user of this org' do
        attrs = Fabricate.attributes_for(:org).merge(users_attributes: [user_attrs])
        expect do
          Org.create!(attrs)
        end.to change { User.count }.by(1)
        expect(User.last.org_id).to eq Org.last.id
      end
    end
  end
end
