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

    before { sign_in user }

    it 'redirects from / to the freelancer project dashboard' do
      visit '/'
      expect(page).to have_current_path('/f/projects')
    end

    it 'completes an entire client/project creation' do
      visit '/f/clients/new'
      fill_in 'org[users_attributes][0][name]', with: Faker::Name.name
      fill_in 'org[users_attributes][0][email]', with: Faker::Internet.email
      name = Faker::Commerce.product_name
      fill_in 'org[projects_attributes][0][name]', with: name
      click_on 'Continue >'
      expect(page).to have_content('Client was successfully created.')
      find('.DayPicker-Day--today').click
      click_on 'Continue >'
      expect(page).to have_content('Milestones were updated.')
      expect(page).to have_content(Milestone.last.formatted_date)
      amount = Money.new(rand(10_000..1_000_00))
      fill_in 'milestone_project[amount]', with: amount
      fill_in 'milestone_project[milestones_attributes][0][amount]', with: amount
      click_on 'Continue >'
      expect(page).to have_content('Payments were updated.')
      visit '/f/projects'
      expect(page).to have_content(name)
      expect(page).to have_content(amount.format)
    end
  end
end
