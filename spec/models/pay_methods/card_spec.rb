require "rails_helper"

RSpec.describe PayMethods::Card do
  subject(:card) { Fabricate(:card_pay_method) }

  let(:amount) { Money.new(rand(10_000..1_000_00)) }

  describe "#bank_account?" do
    it { expect(card.bank_account?).to be false }
  end

  describe "#card?" do
    it { expect(card.card?).to be true }
  end

  describe "#to_s" do
    it { expect(card.to_s).to include(card.last_4) }
  end

  it "charges" do
    expect(card.charge!(amount: amount)).to be_a Stripe::Charge
  end
end
