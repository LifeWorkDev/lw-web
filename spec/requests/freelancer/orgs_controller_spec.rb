require 'rails_helper'

RSpec.describe Freelancer::OrgsController, type: :request do
  let(:freelancer) { Fabricate(:freelancer) }

  before { sign_in freelancer }

  describe 'GET /f/clients/new' do
    let(:org) { assigns(:org) }

    it 'builds milestone project, user' do
      get new_freelancer_org_path
      expect(response).to have_http_status(:ok)
      expect(org.projects.first.type).to eq 'MilestoneProject'
      expect(org.users.size).to eq 1
    end
  end

  describe 'POST /f/clients' do
    let(:org_attributes) { Fabricate.attributes_for(:named_org) }
    let(:new_org) { Org.last }
    let(:new_project) { Project.last }
    let(:new_user) { User.last }
    let(:projects_attributes) { { '0': { name: Faker::Commerce.product_name } } }
    let(:params) do
      {
        org: org_attributes.merge(
          projects_attributes: projects_attributes,
          users_attributes: users_attributes,
        ),
      }
    end

    context 'with new user' do
      let(:users_attributes) { { '0': Fabricate.attributes_for(:user) } }

      it 'creates org, milestone project, user' do
        expect do
          post freelancer_orgs_path, params: params
        end.to change { Org.count }.by(1) &
               change { Project.count }.by(1) &
               change { User.count }.by(1)
        expect(new_org.name).to eq org_attributes[:name]
        expect(new_user.invited_by).to eq freelancer
        expect(new_project.client).to eq new_org
        expect(new_project.freelancer).to eq freelancer
        expect(new_project.type).to eq 'MilestoneProject'
      end
    end

    context 'with existing user' do
      let(:org) { assigns(:org) }
      let(:users_attributes) { { '0': { email: freelancer.email } } }

      it 'returns errors' do
        expect do
          post freelancer_orgs_path, params: params
        end.to not_change { Org.count } &
               not_change { Project.count } &
               not_change { User.count }
        expect(org.errors).not_to be_empty
      end
    end
  end
end
