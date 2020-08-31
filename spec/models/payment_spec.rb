require "rails_helper"

RSpec.describe Payment, type: :model do
  subject(:payment) { Fabricate(:payment) }

  it { is_expected.to monetize(:amount).with_model_currency(:currency) }
  it { is_expected.to monetize(:stripe_fee) }

  describe "callbacks" do
    describe "before_update" do
      it "does nothing if not deposited" do
        allow(payment).to receive(:refund_difference)
        payment.update!(amount: payment.amount + 1.to_money)
        expect(payment).not_to have_received(:refund_difference)
      end

      context "when deposited" do
        before { payment.charge! }

        let(:pay_method) { payment.pay_method }
        let(:pays_for) { payment.pays_for }

        it "partially refunds if amount was reduced" do
          old_amount = payment.amount
          new_amount = payment.amount / 2
          payment_difference = Money.new(old_amount - new_amount)
          refund_amount = payment.client_amount(payment_difference)

          allow(payment).to receive(:partially_refund!)
          allow(pays_for).to receive(:update!)
          payment.update!(amount: new_amount)
          expect(payment.amount).to eq new_amount
          expect(payment).to have_received(:partially_refund!).with(refund_amount).once

          if pays_for.class == Milestone
            expect(pays_for).to have_received(:update!).with(amount: new_amount).once
          else
            expect(pays_for).not_to have_received(:update!)
          end

          if pay_method.fee_percent.zero?
            expect(refund_amount).to eq payment_difference
          else
            expect(refund_amount).to be > payment_difference
          end
        end

        it "raises exception if amount was increased" do
          expect { payment.update(amount: payment.amount + 1.to_money) }.to raise_error(StandardError, "Can't increase the amount of a deposited payment")
        end

        it "does nothing if amount was unchanged" do
          allow(payment).to receive(:refund_difference)
          payment.update(note: Faker::Lorem.sentence)
          expect(payment).not_to have_received(:refund_difference)
        end
      end
    end
  end

  describe "charge!" do
    it "creates acccounting records, changes status" do
      expect { payment.charge! }.to change { DoubleEntry::Line.count }.by(2) &
        change { payment.status }.from("scheduled").to("succeeded")
      expect(payment.stripe_id).to be_present
    end
  end
end
