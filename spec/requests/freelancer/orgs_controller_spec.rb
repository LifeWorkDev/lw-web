require 'rails_helper'

RSpec.describe Freelancer::OrgsController, type: :request do
  let(:user) { Fabricate(:freelancer) }

  before { sign_in user }

  describe 'GET /f/clients/new' do
    let(:org) { assigns(:org) }

    it 'builds a milestone project' do
      get new_freelancer_org_path
      expect(response).to have_http_status(:ok)
      expect(org.projects.first.type).to eq 'MilestoneProject'
      expect(org.users.size).to eq 1
    end
  end

  describe 'POST /f/clients' do
    let(:params) do
      {
        org: Fabricate.attributes_for(:named_org).merge(
          projects_attributes: { '0': { name: Faker::Commerce.product_name } },
          users_attributes: { '0': Fabricate.attributes_for(:user).except(:password) },
        ),
      }
    end

    it 'creates org, user' do
      expect do
        post freelancer_orgs_path, params: params
      end.to change { Org.count }.by(1) &
             change { Project.count }.by(1) &
             change { User.count }.by(1)
      expect(User.last.invited_by).to eq user
      expect(Project.last.client).to eq Org.last
    end
  end
end
