require "rails_helper"

RSpec.describe Payment, type: :model do
  subject(:payment) { Fabricate(:payment) }

  it { is_expected.to monetize(:amount).with_model_currency(:currency) }
  it { is_expected.to monetize(:stripe_fee) }

  describe "#charge!" do
    it "creates accounting records, changes status" do
      expect { payment.charge! }.to change { DoubleEntry::Line.count }.by(4) &
        change { payment.status }.from("scheduled").to("succeeded")
      expect(payment.stripe_id).to be_present
    end
  end

  describe "#issue_refund!" do
    subject(:payment) { Fabricate(:succeeded_payment) }

    it "issues a full refund with new_amount: 0" do
      old_amount = payment.amount

      allow(Stripe::Refund).to receive(:create).and_return(OpenStruct.new({
        id: Faker::Crypto.md5,
        amount: old_amount.cents,
      }))
      payment.issue_refund!(new_amount: 0.to_money, freelancer_refund_cents: payment.pays_for.amount_cents)
      expect(payment.reload.amount).to eq 0
      expect(payment.platform_fee).to eq 0
      expect(Stripe::Refund).to have_received(:create).with({
        amount: old_amount.cents,
        charge: payment.stripe_id,
        metadata: payment.send(:payment_metadata),
        reason: :requested_by_customer,
      }, idempotency_key: anything).once
    end
  end
end
