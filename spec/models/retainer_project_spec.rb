require "rails_helper"

RSpec.describe RetainerProject do
  subject(:project) { Fabricate(:active_retainer_project, status: :client_invited) }

  describe "state machine" do
    describe "#activate!" do
      it "activates project, schedules deposit, emails freelancer" do
        expect {
          project.activate!
        }.to change { project.status }.to("active") &
          enqueue_mail(FreelancerMailer, :retainer_agreed).once &
          enqueue_job(Retainer::DepositJob).once.at(project.deposit_time(project.start_date))
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
    subject(:project) { Fabricate(:active_retainer_project) }

    it "disburses payment, schedules next deposit, emails client & freelancer" do
      payment = Fabricate(:succeeded_payment, pay_method: project.client.primary_pay_method, pays_for: project)

      expect {
        project.disburse!(payment)
      }.to change { payment.reload.status }.to("disbursed") &
        enqueue_mail(ClientMailer, :retainer_disbursed).once &
        enqueue_mail(FreelancerMailer, :retainer_disbursed).once &
        enqueue_job(Retainer::DepositJob).once
    end
  end

  context "when start_date.day == disbursement_day" do
    subject(:project) { Fabricate(:retainer_project, amount_cents: 15_000_00, disbursement_day: 1, start_date: "2020-05-01") }

    describe "#first_client_amount" do
      it { expect(project.first_client_amount).to be >= project.amount }
    end

    describe "#first_amount" do
      it "equals amount" do
        expect(project.first_amount).to eq(15_000.to_money)
      end
    end
  end

  context "when start_date.day != disbursement_day" do
    subject(:project) { Fabricate(:active_retainer_project, amount_cents: 15_000_00, disbursement_day: 1, start_date: "2020-05-25") }

    describe "#first_client_amount" do
      it { expect(project.first_client_amount).to be < project.amount }
    end

    describe "#first_amount" do
      it "prorates correctly" do
        expect(project.first_amount).to eq(3_387.10.to_money)
      end
    end

    context "with a disbursed payment" do
      before { Fabricate(:disbursed_payment, pays_for: project) }

      describe "#client_amount" do
        it { expect(project.client_amount).to be >= project.amount }
      end

      describe "#freelancer_amount" do
        it "calculates correctly" do
          expect(project.freelancer_amount).to eq(14_700.to_money)
        end
      end
    end
  end

  describe "#next_date" do
    context "when start_date.day > disbursement_day" do
      subject(:project) { Fabricate(:retainer_project, disbursement_day: 1, start_date: "2020-05-15") }

      it "calculates correctly" do
        expect(project.next_date).to eq(Date.parse("2020-06-01"))
      end
    end

    context "when start_date.day == disbursement_day" do
      subject(:project) { Fabricate(:retainer_project, disbursement_day: 15, start_date: "2020-05-15") }

      it "calculates correctly" do
        expect(project.next_date).to eq(Date.parse("2020-06-15"))
      end
    end

    context "when start_date.day < disbursement_day" do
      subject(:project) { Fabricate(:retainer_project, disbursement_day: 31, start_date: "2020-05-15") }

      it "calculates correctly" do
        expect(project.next_date).to eq(Date.parse("2020-05-31"))
      end
    end

    context "when start_date.day < disbursement_day in a month with less than 31 days" do
      subject(:project) { Fabricate(:retainer_project, disbursement_day: 31, start_date: "2020-06-15") }

      it "calculates correctly" do
        expect(project.next_date).to eq(Date.parse("2020-06-30"))
      end
    end

    context "when start_date.day is last day of a month with less than 31 days" do
      subject(:project) { Fabricate(:retainer_project, disbursement_day: 31, start_date: "2020-06-30") }

      it "calculates correctly" do
        expect(project.next_date).to eq(Date.parse("2020-07-31"))
      end
    end
  end
end
