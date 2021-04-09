require "rails_helper"

RSpec.describe "Freelancer views", type: :system do
  context "when unauth'd" do
    let(:user) { User.last }
    let(:user_name) { Faker::Name.name }
    let(:user_email) { Faker::Internet.safe_email }
    let(:user_time_zone) { ActiveSupport::TimeZone.basic_us_zone_names.sample }
    let(:user_opt_in) { [true, false].sample }

    it "renders signup form" do
      verify_visit "/"
      expect(page).to have_current_path "/sign_up"
    end

    it "redirects after sign up to user edit, then onboarding video" do
      verify_visit "/sign_up"
      fill_in "user[name]", with: user_name
      fill_in "user[email]", with: user_email
      fill_in "user[password]", with: Faker::Internet.password(special_characters: true)
      find(:checkbox, "user[email_opt_in]").set(user_opt_in)
      expect {
        click_sign_up "/f/user/edit"
      }.to change { User.count }.by(1)
      expect(user.name).to eq user_name
      expect(user.email).to eq user_email
      expect(user.email_opt_in).to eq(user_opt_in)
      select user_time_zone, from: "user[time_zone]"
      fill_in "user[how_did_you_hear_about_us]", with: Faker::Lorem.sentence
      WORK_CATEGORIES.sample(rand(1..WORK_CATEGORIES.size)).each do |category|
        check category, allow_label_click: true
      end
      choose User::WORK_TYPES.sample, allow_label_click: true
      expect {
        click_continue
      }.to change { user.reload.time_zone }.to(user_time_zone) &
        change { user.how_did_you_hear_about_us } &
        change { user.work_category } &
        change { user.work_type }
      expect(page).to have_current_path "/f/content/walkthrough"
    end
  end

  context "when auth'd" do
    let(:user) { Fabricate(:active_user) }
    let(:amount) { Money.new(Fabricate.attributes_for(:milestone)[:amount_cents]) }
    let(:name) { Faker::Commerce.product_name }
    let(:new_project) { Project.last }
    let(:new_milestone) { Milestone.last }

    before { sign_in user }

    it "redirects from / to the new client page" do
      verify_visit "/"
      expect(page).to have_current_path "/f/clients/new"
    end

    def choose_date
      # Choose a random selectable date
      date = all("div", class: %w[DayPicker-Day !DayPicker-Day--disabled !DayPicker-Day--outside]).sample
      Rails.logger.info "Clicking #{date["aria-label"]}"
      date.click
    end

    def invite_expectations
      expect {
        click_continue "/f/projects"
      }.to enqueue_mail(ClientMailer, :invite).once
      expect(page).to have_content("Your client has been emailed an invitation to join the project.")
    end

    def milestone_project_expectations
      expect(new_project.type).to eq "MilestoneProject"
      choose_date
      click_continue
      expect(page).to have_content(new_milestone.formatted_date)
      fill_in "milestone_project[amount]", with: amount
      fill_in "milestone_project[milestones_attributes][0][amount]", with: amount
      fill_in "milestone_project[milestones_attributes][0][description]", with: Faker::Lorem.sentences.join(" ")
      expect {
        click_continue
      }.to change { new_project.reload.amount } &
        change { new_milestone.reload.amount } &
        change { new_milestone.description }
      expect(page).to have_content(name) &
        have_content(amount.format, count: 2) &
        have_content(new_milestone.formatted_date) &
        have_content(new_milestone.description)
      invite_expectations
    end

    def retainer_project_expectations
      expect(new_project.type).to eq "RetainerProject"
      fill_in "retainer_project[amount]", with: amount
      find("#retainer_project_start_date_picker").click
      choose_date
      expect {
        click_continue
      }.to change { new_project.reload.amount } &
        change { new_project.start_date } &
        change { new_project.disbursement_day }
      expect(page).to have_content(name) &
        have_content(amount.format(no_cents_if_whole: true)) &
        have_content(I18n.l(new_project.start_date, format: :text_without_year)) &
        have_content(new_project.disbursement_day.ordinalize)
      invite_expectations
    end

    context "without existing projects" do
      let(:client_user) { User.last }

      def new_client_expectations(project_type)
        verify_visit "/f/projects"
        verify_click "+ Project", "/f/clients/new"
        fill_in "org[users_attributes][0][name]", with: Faker::Name.name
        fill_in "org[users_attributes][0][email]", with: Faker::Internet.safe_email
        fill_in "org[projects_attributes][0][name]", with: name
        first("#org_projects_attributes_0_status option[value=contract_sent]").select_option # Placeholder is first
        choose "org_projects_attributes_0_type_#{project_type}project", allow_label_click: true
        expect {
          click_continue
        }.to change { Org.count }.by(1) &
          change { Project.count }.by(1) &
          change { User.count }.by(1)
        expect(client_user.invited_by).to eq(user)
        expect(page).to have_content("Client was successfully created.")
      end

      context "with stripe account" do
        let(:user) { Fabricate(:user, stripe_id: 1) }

        it "completes client/milestone project creation" do
          new_client_expectations(:milestone)
          expect(page).to have_link "< Back", href: %r{/f/clients/.+/edit$}
          milestone_project_expectations
        end

        it "completes client/retainer project creation" do
          new_client_expectations(:retainer)
          expect(page).to have_link "< Back", href: %r{/f/clients/.+/edit$}
          retainer_project_expectations
        end
      end

      context "without stripe account" do
        it "requires stripe connect" do
          new_client_expectations(%i[milestone retainer].sample)
          expect(page).to have_current_path freelancer_stripe_connect_path
        end
      end
    end

    context "with a project" do
      let(:project) { user.projects.first }
      let(:client) { project.client }
      let(:client_user) { client.primary_contact }

      describe "that is active" do
        let(:user) { Fabricate(:active_freelancer) }

        def new_project_expectations(project_type)
          verify_visit "/f/projects"
          verify_click "+ Project", "/f/projects/new"
          all("#project_org_id option")[1].select_option # Placeholder is first
          fill_in "project[name]", with: name
          first("#project_status option[value=contract_sent]").select_option # Placeholder is first
          choose "project_type_#{project_type}project", allow_label_click: true
          click_continue
          expect(page).to have_content("Project was successfully created.")
          expect(page).to have_link "< Back", href: %r{/f/projects/.+/edit$}
        end

        it "redirects from / to the project dashboard" do
          verify_visit "/"
          expect(page).to have_current_path freelancer_projects_path
        end

        it "completes milestone project creation for an existing client" do
          new_project_expectations(:milestone)
          milestone_project_expectations
        end

        it "completes retainer project creation for an existing client" do
          new_project_expectations(:retainer)
          retainer_project_expectations
        end

        it "can view timeline" do
          project.try(:milestones)&.first&.update!(status: :deposited)
          verify_visit "/f/projects"
          verify_click project.name, "/f/projects/#{project.slug}/timeline"
          expect(page).to have_content("#{project.name} timeline")
        end

        it "can view clients index" do
          verify_visit "/f/clients"
          expect(page).to have_content client.name
          expect(page).to have_content client_user.email
        end
      end

      describe "that is pending" do
        let(:user) { Fabricate(:freelancer, project_type: :milestone) }

        it "redirects from / to the edit client page for the first project" do
          verify_visit "/"
          expect(page).to have_current_path edit_freelancer_org_path(client)
        end

        it "can edit" do
          verify_visit "/f/projects"
          verify_click project.name, edit_freelancer_org_path(project.client)
          click_continue status_freelancer_project_path(project)
          expect(page).not_to have_content "updated"
        end
      end
    end
  end
end
