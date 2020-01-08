require 'rails_helper'

RSpec.describe PayMethod, type: :model do
  let(:amount) { Money.new(rand(10_000..1_000_00)) }

  describe 'Bank Account' do
    subject(:bank_account) { Fabricate(:bank_account_pay_method) }

    describe '#bank_account?' do
      it { expect(bank_account.bank_account?).to eq true }
    end

    describe '#card?' do
      it { expect(bank_account.card?).to eq false }
    end

    describe '#to_s' do
      it { expect(bank_account.to_s).to include(bank_account.last_4) }
    end

    it 'charges' do
      expect(bank_account.charge!(amount: amount)).to be_a Stripe::Charge
    end
  end

  describe 'Card' do
    subject(:card) { Fabricate(:card_pay_method) }

    describe '#bank_account?' do
      it { expect(card.bank_account?).to eq false }
    end

    describe '#card?' do
      it { expect(card.card?).to eq true }
    end

    describe '#to_s' do
      it { expect(card.to_s).to include(card.last_4) }
    end

    it 'charges' do
      expect(card.charge!(amount: amount)).to be_a Stripe::PaymentIntent
    end
  end
end
