require "rails_helper"

RSpec.describe Payment, type: :model do
  subject(:payment) { Fabricate(:payment) }

  it { is_expected.to monetize(:amount).with_model_currency(:currency) }
  it { is_expected.to monetize(:stripe_fee) }

  describe "charge!" do
    it "creates acccounting records, changes status" do
      expect { payment.charge! }.to change { DoubleEntry::Line.count }.by(2) &
                                    change { payment.status }.from("scheduled").to("succeeded")
      expect(payment.stripe_id).to be_present
    end
  end
end
