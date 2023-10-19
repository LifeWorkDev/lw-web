require "rails_helper"

RSpec.describe User do
  subject(:user) { Fabricate(:user) }

  describe "defaults" do
    it "sets a random password when provided value is nil" do
      expect { Fabricate(:user).encrypted_password }.not_to raise_error
    end

    it "sets a random password when provided value is blank" do
      expect { Fabricate(:user, password: "").encrypted_password }.not_to raise_error
    end

    it "does not override a provided password" do
      password = Faker::Internet.password
      expect(Fabricate(:user, password: password).valid_password?(password)).to be true
    end
  end

  describe ".invite" do
    it "does not send invitation email" do
      expect {
        User.invite!(Fabricate.attributes_for(:user))
      }.to change { User.count }.by(1) &
        not_enqueue_mail
    end
  end

  describe "#max_pending_project_status" do
    it "is nil with no projects" do
      expect(user.max_pending_project_status).to be_nil
    end

    context "when a freelancer with projects" do
      let(:user) { Fabricate(:freelancer) }

      it "is pending even with projects in a non-pending status" do
        Fabricate(:milestone_project, freelancer: user, status: :active)
        expect(user.max_pending_project_status).to eq Project.aasm.initial_state.to_s
      end

      it "is farthest pending status" do
        Fabricate(:milestone_project, freelancer: user, status: :contract_sent)
        Fabricate(:milestone_project, freelancer: user, status: :proposal_sent)
        expect(user.max_pending_project_status).to eq "contract_sent"
      end
    end
  end

  describe "#local_time" do
    let(:user) { Fabricate(:active_user) }

    it "handles a user with a time_zone" do
      time = user.local_time(Date.current)
      expect(time).to be_a ActiveSupport::TimeWithZone
      expect(time.time_zone.name).to eq user.time_zone
    end

    it "handles a user without a time_zone" do
      user = Fabricate.build(:user, time_zone: nil)
      time = user.local_time(Date.current)
      expect(time).to be_a ActiveSupport::TimeWithZone
      expect(time.time_zone.name).to eq "Pacific Time (US & Canada)"
    end
  end
end
