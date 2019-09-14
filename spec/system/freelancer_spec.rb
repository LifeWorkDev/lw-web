require 'rails_helper'

RSpec.describe 'Freelancer views', type: :system do
  context "when unauth'd" do
    it 'renders signup form' do
      visit '/'
      expect(page).to have_content 'sign up'
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
      expect do
        click_on 'Continue >'
      end.to change { Org.count }.by(1) &
             change { Project.count }.by(1)
      expect(page).to have_content('Client was successfully created.')
      find('.flatpickr-day.today').click
      click_on 'Continue >'
      new_milestone = Milestone.last
      expect(page).to have_content('Milestones were updated.') &
                      have_content(new_milestone.formatted_date)
      amount = Money.new(rand(10_000..1_000_00))
      fill_in 'milestone_project[amount]', with: amount
      fill_in 'milestone_project[milestones_attributes][0][amount]', with: amount
      fill_in 'milestone_project[milestones_attributes][0][description]', with: Faker::Lorem.sentences.join(' ')
      click_on 'Continue >'
      new_milestone.reload
      expect(page).to have_content('Payments were updated.') &
                      have_content(name) &
                      have_content(amount.format, count: 2) &
                      have_content(new_milestone.formatted_date) &
                      have_content(new_milestone.description)
      expect do
        click_on 'Continue >'
      end.to enqueue_job(ActionMailer::MailDeliveryJob)
      expect(page).to have_content('Your client has been emailed an invitation to join the project.')
    end
  end
end
