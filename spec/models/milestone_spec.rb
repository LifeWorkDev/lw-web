require "rails_helper"

RSpec.describe Milestone, type: :model do
  subject(:milestone) { Fabricate(:milestone) }

  describe "#next" do
    subject(:milestone) { project.milestones.first }

    let(:next_milestone) { project.milestones.second }
    let(:project) { Fabricate(:milestone_project_with_milestones) }

    context "when next is pending" do
      it "returns the next milestone by date" do
        expect(milestone.next).to eq(next_milestone)
      end
    end

    context "when next is deposited" do
      before { next_milestone.update!(status: :deposited) }

      it "returns the next milestone by date" do
        expect(milestone.next).to be_nil
      end
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

  context "with payment attached" do
    subject(:milestone) { project.milestones.first }

    let(:client) { project.client }
    let(:freelancer) { Fabricate(:active_freelancer, project_type: :milestone) }
    let(:pay_method) { client.primary_pay_method }
    let(:project) { freelancer.projects.first }
    let(:user) { client.primary_contact }

    describe "callbacks" do
      describe "before_update" do
        it "does nothing if pending" do
          allow(milestone).to receive(:update_payment_amount)
          milestone.amount += 1.to_money
          milestone.save
          expect(milestone).not_to have_received(:update_payment_amount)
        end

        shared_examples "refund" do
          it "fully refunds if amount was changed to 0" do
            old_amount = milestone.amount

            payment = milestone.latest_payment
            allow(milestone).to receive(:latest_payment) { payment }
            allow(payment).to receive(:issue_refund!)
            milestone.update(amount: 0)
            expect(milestone.reload.amount).to eq 0
            expect(payment).to have_received(:issue_refund!).with(new_amount: milestone.client_amount, freelancer_refund_cents: old_amount.cents).once
          end

          it "partially refunds if amount was reduced" do
            old_amount = milestone.amount
            new_amount = old_amount / 2
            refund_amount = old_amount - new_amount

            payment = milestone.latest_payment
            allow(milestone).to receive(:latest_payment) { payment }
            allow(payment).to receive(:issue_refund!)
            milestone.update(amount: new_amount)
            expect(milestone.reload.amount).to eq new_amount
            expect(payment).to have_received(:issue_refund!).with(new_amount: milestone.client_amount, freelancer_refund_cents: refund_amount.cents).once
          end

          it "raises exception if amount was increased" do
            milestone.amount += 1.to_money
            expect { milestone.save }.to raise_error(StandardError, "Can't increase the amount of a #{milestone.status} milestone")
          end

          it "does nothing if amount was unchanged" do
            allow(milestone).to receive(:update_payment_amount)
            milestone.update(description: Faker::Lorem.sentence)
            expect(milestone).not_to have_received(:update_payment_amount)
          end
        end

        context "when deposited" do
          before { milestone.deposit! }

          include_examples "refund"
        end

        context "when paid" do
          before do
            milestone.deposit!
            milestone.pay!
          end

          include_examples "refund"
        end
      end
    end

    describe "state machine" do
      let(:payment) { milestone.payments.last }

      describe "#deposit!" do
        before { project.update!(status: :client_invited) }

        it "doesn't schedule milestone approaching emails if they would be in the past" do
          milestone.update!(date: Date.current)
          expect {
            milestone.deposit!
          }.to not_enqueue_mail(FreelancerMailer, :milestone_approaching) &
            not_enqueue_mail(ClientMailer, :milestone_approaching)
        end

        it "charges client's primary pay method, activates project, emails freelancer, emails client" do
          deposit_return_value = nil
          expect {
            deposit_return_value = milestone.deposit!
          }.to enqueue_mail(FreelancerMailer, :milestone_deposited).once &
            enqueue_mail(ClientMailer, :milestone_deposited).once &
            enqueue_mail(FreelancerMailer, :milestone_approaching).once.at(milestone.freelancer_reminder_time) &
            enqueue_mail(ClientMailer, :milestone_approaching).once.at(milestone.client_reminder_time) &
            enqueue_job(Milestones::PayJob).once.at(milestone.payment_time)
          expect(deposit_return_value).to be true
          expect(project.reload.active?).to be true
          expect(payment.successful?).to be true
          expect(payment.amount).to eq milestone.client_amount
          expect(payment.pays_for).to eq milestone
          expect(payment.pay_method).to eq milestone.client.primary_pay_method
          expect(payment.paid_by).to be_nil
        end

        it "doesn't activate project, email freelancer, or email client if payment fails" do
          # Stripe-Ruby-Mock doesn't support forcing failures for PaymentIntents (used by Card payments) yet
          Fabricate(:bank_account_pay_method, org: client)
          StripeMock.prepare_card_error(:card_declined)

          deposit_return_value = nil
          expect {
            deposit_return_value = milestone.deposit!
          }.to not_enqueue_mail(FreelancerMailer, :milestone_deposited) &
            not_enqueue_mail(ClientMailer, :milestone_deposited) &
            not_enqueue_mail(FreelancerMailer, :milestone_approaching) &
            not_enqueue_mail(ClientMailer, :milestone_approaching) &
            not_enqueue_job(Milestones::PayJob)
          expect(deposit_return_value).to be false
          expect(project.reload.active?).to be false
          expect(payment.failed?).to be true
          expect(payment.amount).to eq milestone.client_amount
          expect(payment.pays_for).to eq milestone
          expect(payment.pay_method).to eq milestone.client.primary_pay_method
          expect(payment.paid_by).to be_nil
        end

        it "sets a user if provided" do
          milestone.deposit!(user)
          expect(payment.paid_by).to eq user
        end
      end

      describe "#pay!" do
        shared_examples "pay" do
          it "creates Stripe transfers, emails client & freelancer, schedules next deposit" do
            milestone.update(status: :deposited)
            allow(Stripe::Transfer).to receive(:create).and_call_original
            expect {
              milestone.pay!
            }.to enqueue_mail(ClientMailer, :milestone_paid).once &
              enqueue_mail(FreelancerMailer, :milestone_paid).once &
              enqueue_job(Milestones::DepositJob).once
            expect(Stripe::Transfer).to have_received(:create).once
          end
        end

        context "with pending payment" do
          before { Fabricate(:pending_payment, pays_for: milestone) }

          include_examples "pay"
        end

        context "with succeeded payment" do
          before { Fabricate(:succeeded_payment, pays_for: milestone) }

          include_examples "pay"
        end
      end
    end
  end

  describe "validations" do
    it { is_expected.to validate_numericality_of(:amount).is_greater_than_or_equal_to(10).on(:create) }
  end
end
