require 'rails_helper'

RSpec.describe 'Client views', type: :system do
  context "when auth'd" do
    let(:user) { Fabricate(:client) }
    let(:org) { user.org }
    let(:project) { Fabricate(:milestone_project_with_milestones, client: org) }

    before { sign_in user }

    it 'redirects from / to the client project dashboard' do
      visit '/'
      expect(page).to have_current_path('/c/projects')
    end

    def shared_expectations
      visit polymorphic_path [:payments, :client, project]
      project.milestones.each do |milestone|
        expect(page).to have_selector("input[value='#{milestone.amount.format(symbol: false)}']") &
                        have_content(milestone.formatted_date) &
                        have_selector("input[value='#{milestone.description}']")
      end
      expect(page).to have_selector("input[value='#{project.amount.format(symbol: false)}']")
      click_on 'Continue >'
    end

    context 'without existing pay method' do
      it 'prompts to create a new bank account' do
        shared_expectations
        expect(page).to have_current_path("/c/bank_accounts/new?project=#{project.slug}")
      end
    end

    context 'with existing pay method' do
      before { Fabricate(:bank_account_pay_method, created_by: user, org: org) }

      it 'proceeds directly to deposit' do
        shared_expectations
        expect(page).to have_current_path(polymorphic_path([:deposit, :client, project]))
      end
    end
  end
end
