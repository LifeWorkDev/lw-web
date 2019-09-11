require 'rails_helper'

RSpec.describe Freelancer::OrgsController, type: :request do
  let(:user) { Fabricate(:freelancer) }

  before { sign_in user }

  describe 'GET /f/clients/new' do
    it 'works! (now write some real specs)' do
      get new_freelancer_org_path
      expect(response).to have_http_status(:ok)
      expect(assigns(:org).projects.first.type).to eq 'MilestoneProject'
    end
  end
end
