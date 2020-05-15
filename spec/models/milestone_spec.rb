require "rails_helper"

RSpec.describe Milestone, type: :model do
  subject(:milestone) { Fabricate(:milestone) }

  describe "#next" do
    subject(:milestone) { project.milestones.first }

    let(:project) { Fabricate(:milestone_project_with_milestones) }

    it "returns the next milestone by date" do
      project.reload # Make sure milestones are loaded from the DB in correct order
      expect(milestone.next.date).to eq(project.milestones.pluck(:date).second)
    end
  end

  describe "#reminder_date" do
    subject(:milestone) { Fabricate(:milestone, date: 1.week.from_now.beginning_of_week(:monday)) }

    it "handles weekends correctly" do
      expect((milestone.date - milestone.reminder_date).to_i).to be >= 5
    end
  end

  describe "#reminder_time" do
    it "sets hour to 9am" do
      expect(milestone.reminder_time(User.all.sample).hour).to eq 9
    end
  end

  describe "state machine" do
    subject(:milestone) { project.milestones.first }

    let(:client) { project.client }
    let(:freelancer) { Fabricate(:active_freelancer, project_type: :milestone) }
    let(:pay_method) { client.primary_pay_method }
    let(:project) { freelancer.projects.first }
    let(:payment) { Payment.last }
    let(:user) { client.primary_contact }

    describe "#deposit!" do
      it "doesn't schedule milestone approaching emails if they would be in the past" do
        milestone.update!(date: Date.current)
        expect {
          milestone.deposit!
        }.to not_enqueue_mail(FreelancerMailer, :milestone_approaching) &
          not_enqueue_mail(ClientMailer, :milestone_approaching)
      end

      it "charges client's primary pay method, activates project, emails freelancer, emails client" do
        expect {
          milestone.deposit!
        }.to enqueue_mail(FreelancerMailer, :milestone_deposited).once &
          enqueue_mail(ClientMailer, :milestone_deposited).once &
          enqueue_mail(FreelancerMailer, :milestone_approaching).once.at(milestone.freelancer_reminder_time) &
          enqueue_mail(ClientMailer, :milestone_approaching).once.at(milestone.client_reminder_time) &
          enqueue_job(Milestones::PayJob).once.at(milestone.payment_time)
        expect(project.reload.active?).to be true
        expect(payment.amount).to eq milestone.client_amount
        expect(payment.pays_for).to eq milestone
        expect(payment.pay_method).to eq milestone.client.primary_pay_method
        expect(payment.user).to be_nil
      end

      it "sets a user if provided" do
        milestone.deposit!(user)
        expect(payment.user).to eq user
      end
    end

    describe "#pay!" do
      before { Fabricate(:succeeded_payment, pays_for: milestone) }

      it "creates Stripe transfers, emails client & freelancer, schedules next deposit" do
        milestone.update(status: :deposited)
        allow(Stripe::Transfer).to receive(:create).and_call_original
        expect {
          milestone.pay!
        }.to enqueue_mail(ClientMailer, :milestone_paid).once &
          enqueue_mail(FreelancerMailer, :milestone_paid).once &
          enqueue_job(Milestones::DepositJob).once.at(milestone.deposit_time)
        expect(Stripe::Transfer).to have_received(:create).once
      end
    end
  end
end
