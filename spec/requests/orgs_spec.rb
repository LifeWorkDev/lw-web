require 'rails_helper'

RSpec.describe 'Orgs', type: :request do
  describe 'GET /orgs' do
    it 'works! (now write some real specs)' do
      get orgs_path
      expect(response).to have_http_status(:ok)
    end
  end
end
