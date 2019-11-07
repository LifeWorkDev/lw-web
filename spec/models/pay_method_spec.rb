require 'rails_helper'

RSpec.describe PayMethod, type: :model do
  let(:amount) { Money.new(rand(10_000..1_000_00)) }

  describe 'Bank Account' do
    subject(:bank_account) { Fabricate(:bank_account_pay_method) }

    it 'fabricates' do
      expect(bank_account.stripe_id).to be_present
    end

    it 'charges' do
      expect(bank_account.charge!(amount: amount)).to be_a Stripe::Charge
    end
  end

  describe 'Card' do
    subject(:card) { Fabricate(:card_pay_method) }

    it 'fabricates' do
      expect(card.stripe_id).to be_present
    end

    it 'charges' do
      expect(card.charge!(amount: amount)).to be_a Stripe::PaymentIntent
    end
  end
end
