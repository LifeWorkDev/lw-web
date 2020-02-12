require 'rails_helper'

RSpec.describe PayMethods::BankAccount, type: :model do
  subject(:bank_account) { Fabricate(:bank_account_pay_method) }

  let(:amount) { Money.new(rand(10_000..1_000_00)) }

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
