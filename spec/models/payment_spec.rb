require "rails_helper"

RSpec.describe Payment do
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
    def issue_refund(new_amount)
      old_amount = payment.amount
      new_amount = new_amount.to_money
      refund_amount = old_amount.cents - new_amount.cents

      allow(Stripe::Refund).to receive(:create).and_return(OpenStruct.new({
        id: Faker::Crypto.md5,
        amount: refund_amount,
      }))
      payment.issue_refund!(new_amount: new_amount, freelancer_refund_cents: payment.pays_for.amount_cents)
      expect(payment.reload.amount).to eq new_amount
      expect(Stripe::Refund).to have_received(:create).with({
        amount: refund_amount,
        charge: payment.stripe_id,
        metadata: payment.send(:payment_metadata),
        reason: :requested_by_customer,
      }, idempotency_key: anything).once
    end

    shared_examples "full_refund" do
      it "issues a full refund with new_amount: 0" do
        issue_refund(0)
        expect(payment.refunded?).to be true
        expect(payment.platform_fee).to eq 0
        expect(payment.processing_fee).to eq 0
      end
    end

    shared_examples "partial_refund" do |status|
      it "issues a partial refund with new_amount: half of old amount" do
        issue_refund(payment.amount / 2)
        expect(payment.send("#{status}?")).to be true
      end
    end

    context "with a succeeded payment" do
      subject(:payment) { Fabricate(:succeeded_payment) }

      include_examples "full_refund"
      include_examples "partial_refund", :partially_refunded
    end

    context "with a disbursed payment" do
      subject(:payment) { Fabricate(:disbursed_payment) }

      include_examples "full_refund"
      include_examples "partial_refund", :disbursed
    end
  end
end
