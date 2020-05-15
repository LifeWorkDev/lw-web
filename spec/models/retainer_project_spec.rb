require "rails_helper"

RSpec.describe RetainerProject, type: :model do
  subject(:project) { Fabricate(:active_retainer_project, status: :client_invited) }

  describe "state machine" do
    describe "#activate!" do
      it "activates project, schedules deposit, emails freelancer" do
        expect {
          project.activate!
        }.to change { project.status }.to("active") &
          enqueue_mail(FreelancerMailer, :retainer_agreed).once &
          enqueue_job(Retainer::DepositJob).once.at(project.deposit_time)
      end
    end
  end

  describe "#deposit!" do
    it "activates project, schedules disbursement, emails client & freelancer" do
      expect {
        project.deposit!
      }.to change { project.status }.to("active") &
        enqueue_mail(ClientMailer, :retainer_deposited).once &
        enqueue_mail(FreelancerMailer, :retainer_deposited).once &
        enqueue_job(Retainer::DisburseJob).once.at(project.disbursement_time)
    end
  end

  describe "#disburse!" do
    it "disburses payment, schedules next deposit, emails client & freelancer" do
      payment = Fabricate(:succeeded_payment, pay_method: project.client.primary_pay_method, pays_for: project)

      expect {
        project.disburse!
      }.to change { payment.reload.status }.to("disbursed") &
        enqueue_mail(ClientMailer, :retainer_disbursed).once &
        enqueue_mail(FreelancerMailer, :retainer_disbursed).once &
        enqueue_job(Retainer::DepositJob).once.at(project.deposit_time)
    end
  end

  describe "#next_date" do
    it { expect(project.next_date.month).to eq project.start_date.month + 1 }
    it { expect(project.next_date.day).to be <= project.start_date.day }
  end
end
