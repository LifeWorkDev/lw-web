require 'rails_helper'

RSpec.describe 'Freelancer views', type: :system do
  context "when unauth'd" do
    let(:user) { User.last }
    let(:user_name) { Faker::Name.name }
    let(:user_email) { Faker::Internet.safe_email }
    let(:user_time_zone) { ActiveSupport::TimeZone.basic_us_zone_names.sample }

    it 'renders signup form' do
      verify_visit '/'
      expect(page).to have_current_path '/sign_up'
    end

    it 'redirects after sign up to user edit, then onboarding video' do
      verify_visit '/sign_up'
      fill_in 'user[name]', with: user_name
      fill_in 'user[email]', with: user_email
      fill_in 'user[password]', with: Faker::Internet.password(special_characters: true)
      expect do
        click_sign_up
      end.to change { User.count }.by(1)
      expect(user.name).to eq user_name
      expect(user.email).to eq user_email
      expect(page).to have_current_path '/f/user/edit'
      select user_time_zone, from: 'user[time_zone]'
      WORK_CATEGORIES.sample(rand(1..WORK_CATEGORIES.size)).each do |category|
        check category, allow_label_click: true
      end
      choose User::WORK_TYPES.sample, allow_label_click: true
      expect do
        click_continue
      end.to change { user.reload.time_zone }.to(user_time_zone) &
             change { user.work_category } &
             change { user.work_type }
      expect(page).to have_current_path '/f/content/walkthrough'
    end
  end

  context "when auth'd" do
    let(:user) { Fabricate(:active_user) }
    let(:amount) { Money.new(rand(100_00..1_000_00)) }
    let(:name) { Faker::Commerce.product_name }
    let(:new_project) { Project.last }
    let(:new_milestone) { Milestone.last }

    before { sign_in user }

    it 'redirects from / to the freelancer project dashboard' do
      verify_visit '/'
      expect(page).to have_current_path '/f/projects'
    end

    def milestone_project_expectations
      # Choose a random selectable date
      date = all('div', class: %w[DayPicker-Day !DayPicker-Day--disabled !DayPicker-Day--outside]).sample
      Rails.logger.info "Clicking #{date['aria-label']}"
      date.click
      click_continue
      expect(page).to have_content('Milestones were updated.') &
                      have_content(new_milestone.formatted_date)
      fill_in 'milestone_project[amount]', with: amount
      fill_in 'milestone_project[milestones_attributes][0][amount]', with: amount
      fill_in 'milestone_project[milestones_attributes][0][description]', with: Faker::Lorem.sentences.join(' ')
      expect do
        click_continue
      end.to change { new_project.reload.amount } &
             change { new_milestone.reload.amount } &
             change { new_milestone.description }
      expect(page).to have_content('Payments were updated.') &
                      have_content(name) &
                      have_content(amount.format, count: 2) &
                      have_content(new_milestone.formatted_date) &
                      have_content(new_milestone.description)
      expect do
        click_continue
      end.to enqueue_mail(ClientMailer, :invite).once
      expect(page).to have_content('Your client has been emailed an invitation to join the project.')
      expect(page).to have_current_path '/f/projects'
    end

    context 'without existing projects' do
      let(:client_user) { User.last }

      def new_client_expectations
        verify_visit '/f/projects'
        verify_click '+ Project'
        expect(page).to have_current_path '/f/clients/new'
        fill_in 'org[users_attributes][0][name]', with: Faker::Name.name
        fill_in 'org[users_attributes][0][email]', with: Faker::Internet.safe_email
        fill_in 'org[projects_attributes][0][name]', with: name
        first('#org_projects_attributes_0_status option[value=contract_sent]').select_option # Placeholder is first
        expect do
          click_continue
        end.to change { Org.count }.by(1) &
               change { Project.count }.by(1) &
               change { User.count }.by(1)
        expect(client_user.invited_by).to eq(user)
        expect(page).to have_content('Client was successfully created.')
      end

      context 'with stripe account' do
        let(:user) { Fabricate(:user, stripe_id: 1) }

        it 'completes an entire client/project creation' do
          new_client_expectations
          expect(page).to have_link '< Back', href: %r{/f/clients/.+/edit$}
          milestone_project_expectations
        end
      end

      context 'without stripe account' do
        it 'requires stripe connect' do
          new_client_expectations
          expect(page).to have_current_path freelancer_stripe_connect_path
        end
      end
    end

    context 'with existing project' do
      let(:user) { Fabricate(:active_freelancer) }
      let(:project) { user.projects.first }
      let(:client_user) { project.client.primary_contact }

      it 'completes project creation for an existing client' do
        verify_visit '/f/projects'
        verify_click '+ Project'
        expect(page).to have_current_path '/f/milestone_projects/new'
        all('#milestone_project_org_id option')[1].select_option # Placeholder is first
        first('#milestone_project_status option[value=contract_sent]').select_option # Placeholder is first
        fill_in 'milestone_project[name]', with: name
        click_continue
        expect(page).to have_content('Project was successfully created.')
        expect(page).to have_link '< Back', href: %r{/f/milestone_projects/.+/edit$}
        milestone_project_expectations
      end

      context 'when pending' do
        let(:user) { Fabricate(:freelancer) }

        it 'can edit pending project' do
          verify_visit '/f/projects'
          verify_click project.name
          expect(page).to have_current_path edit_freelancer_org_path(project.client)
          click_continue
          expect(page).not_to have_content 'updated'
          expect(page).to have_current_path status_freelancer_project_path(project)
        end
      end

      it 'can view comments for an active project' do
        verify_visit '/f/projects'
        verify_click project.name
        expect(page).to have_current_path "/f/milestone_projects/#{project.slug}/comments"
      end
    end
  end
end
