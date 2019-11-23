require 'rails_helper'

RSpec.describe 'Client views', type: :system do
  context "when unauth'd" do
    context 'when invited' do
      let(:project) { Fabricate(:milestone_project) }
      let(:user) { User.invite!(email: Faker::Internet.safe_email, name: Faker::Name.name, org: project.client) }
      let(:new_name) { Faker::Name.name }
      let(:new_email) { Faker::Internet.safe_email }
      let(:time_zone) { ActiveSupport::TimeZone.basic_us_zones.sample.name }

      before { user.invite! }

      it 'updates name, email, tme zone, status when accepting an invitation' do
        url = accept_user_invitation_path(invitation_token: user.raw_invitation_token)

        visit url
        fill_in 'user[name]', with: new_name
        fill_in 'user[email]', with: new_email
        fill_in 'user[password]', with: Faker::Internet.password(special_characters: true)
        select time_zone, from: 'user[time_zone]'
        expect do
          click_on 'Sign up'
        end.to change { user.reload.name }.to(new_name) &
               change { user.email }.to(new_email) &
               change { user.time_zone }.to(time_zone) &
               change { user.status }.from('pending').to('active')
      end
    end
  end

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
        expect(page).to have_selector("input[value='#{milestone.amount.input_format}']") &
                        have_content(milestone.formatted_date) &
                        have_selector("input[value='#{milestone.description}']")
      end
      expect(page).to have_selector("input[value='#{project.amount.input_format}']")
      click_on 'Continue >'
    end

    context 'without existing pay method' do
      it 'prompts to create a new bank account' do
        shared_expectations
        expect(page).to have_current_path("/c/pay_methods?project=#{project.slug}")
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
