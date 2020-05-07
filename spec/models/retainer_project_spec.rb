require "rails_helper"

RSpec.describe RetainerProject, type: :model do
  subject(:project) { Fabricate(:retainer_project) }

  describe "state machine" do
    describe "#activate!" do
      subject(:project) { Fabricate(:retainer_project, status: :client_invited) }

      it "activates project, emails freelancer" do
        expect {
          project.activate!
        }.to change { project.status }.to("active") &
          enqueue_mail(FreelancerMailer, :retainer_agreed).once
      end
    end
  end

  describe "#next_date" do
    it { expect(project.next_date.month).to eq project.start_date.month + 1 }
    it { expect(project.next_date.day).to be <= project.start_date.day }
  end
end
