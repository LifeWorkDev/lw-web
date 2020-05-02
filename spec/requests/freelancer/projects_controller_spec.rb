require "rails_helper"

RSpec.describe Freelancer::ProjectsController, type: :request do
  let(:user) { Fabricate(:freelancer) }

  before { sign_in user }

  describe "GET /f/projects" do
    it "works! (now write some real specs)" do
      get freelancer_projects_path
      expect(response).to have_http_status(:ok)
    end
  end
end
