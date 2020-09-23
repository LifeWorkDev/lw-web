require "rails_helper"

RSpec.describe "Client views", type: :system do
  context "when unauth'd" do
    context "when invited" do
      let(:client) { project.client }
      let(:user) { User.invite!(email: Faker::Internet.safe_email, name: Faker::Name.name, org: project.client) }
      let(:new_name) { Faker::Name.name }
      let(:new_email) { Faker::Internet.safe_email }
      let(:user_opt_in) { [true, false].sample }
      let(:time_zone) { ActiveSupport::TimeZone.basic_us_zones.sample.name }

      before { user.invite! }

      def shared_expectations(project_path)
        url = accept_user_invitation_path(invitation_token: user.raw_invitation_token)

        verify_visit url
        fill_in "user[name]", with: new_name
        fill_in "user[email]", with: new_email
        fill_in "user[password]", with: Faker::Internet.password(special_characters: true)
        select time_zone, from: "user[time_zone]"
        find(:checkbox, "user[email_opt_in]").set(user_opt_in)
        expect {
          click_sign_up edit_client_org_path
        }.to change { user.reload.name }.to(new_name) &
          change { user.email }.to(new_email) &
          change { user.time_zone }.to(time_zone) &
          change { user.status }.from("pending").to("active")
        expect(user.email_opt_in).to eq(user_opt_in)
        WORK_CATEGORIES.sample(rand(1..WORK_CATEGORIES.size)).each do |category|
          check category, allow_label_click: true
        end
        choose Org::WORK_FREQUENCY.sample, allow_label_click: true
        expect {
          click_continue project_path
        }.to change { client.reload.work_category } &
          change { client.work_frequency }
      end

      context "to a milestone project" do
        let(:project) { Fabricate(:milestone_project_with_milestones) }
        let(:milestone_amount_difference) { [-1, 1].sample.to_money }
        let(:new_project_amount) { project.amount + milestone_amount_difference }
        let(:new_milestone_amount) { milestone.amount + milestone_amount_difference }
        let(:milestone_index) { rand(0..project.milestones.size - 1) }
        let(:milestone) { project.reload.milestones[milestone_index] }

        it "updates name, email, email opt in, time zone, status, and allows updating payment schedule when accepting" do
          shared_expectations(polymorphic_path([:payment, :client, project]))
          fill_in "milestone_project[milestones_attributes][#{milestone_index}][amount]", with: new_milestone_amount
          fill_in "milestone_project[milestones_attributes][#{milestone_index}][description]", with: Faker::Lorem.sentences.join(" ")
          fill_in "milestone_project[amount]", with: new_project_amount
          expect {
            click_continue client_pay_methods_path(project: project)
          }.to change { project.reload.amount } &
            change { milestone.reload.amount } &
            change { milestone.description }
        end
      end

      context "to a retainer project" do
        let(:project) { Fabricate(:retainer_project) }

        it "updates name, email, email opt in, time zone, status, and asks for a payment method when accepting" do
          shared_expectations(client_pay_methods_path(project: project))
        end
      end
    end
  end

  context "when auth'd" do
    let(:user) { Fabricate(:active_client) }
    let(:org) { user.org }
    let(:project) { Fabricate(:milestone_project_with_milestones, client: org, status: :client_invited) }

    before { sign_in user }

    context "when onboarding" do
      it "redirects from / to the org edit page" do
        verify_visit "/"
        expect(page).to have_current_path edit_client_org_path
      end
    end

    context "when finished onboarding" do
      before { project } # Fabricate

      it "redirects from / to the client project dashboard" do
        org.update(work_frequency: Org::WORK_FREQUENCY.sample)
        verify_visit "/"
        expect(page).to have_current_path "/c/pay_methods?project=#{project.slug}"
      end
    end

    def shared_expectations
      verify_visit polymorphic_path [:payment, :client, project]
      project.milestones.each do |milestone|
        expect(page).to have_selector("input[value='#{milestone.amount.input_format}']") &
          have_content(milestone.formatted_date) &
          have_selector("input[value='#{milestone.description}']")
      end
      expect(page).to have_selector("input[value='#{project.amount.input_format}']")
      click_continue
    end

    context "without existing pay method" do
      it "prompts to link one" do
        shared_expectations
        expect(page).to have_current_path "/c/pay_methods?project=#{project.slug}"
      end
    end

    context "with existing pay method" do
      let(:org) { Fabricate(:org_with_pay_method) }
      let(:user) { org.primary_contact }

      it "proceeds directly to deposit" do
        shared_expectations
        expect(page).to have_current_path polymorphic_path([:deposit, :client, project.becomes(Project)])
      end
    end
  end
end
