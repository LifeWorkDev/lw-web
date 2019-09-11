require 'rails_helper'

RSpec.describe 'Freelancer views', type: :system do
  context "when unauth'd" do
    it 'renders login form' do
      visit '/'
      expect(page).to have_content 'log in'
    end
  end

  context "when auth'd" do
    let(:user) { Fabricate(:freelancer) }

    before do
      sign_in(user)
      visit '/'
    end

    it 'redirects to the freelancer project dashboard' do
      expect(page).to have_current_path('/f/projects')
    end
  end
end
