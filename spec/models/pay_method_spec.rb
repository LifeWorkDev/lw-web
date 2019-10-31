require 'rails_helper'

RSpec.describe PayMethod, type: :model do
  describe 'Bank Account' do
    subject(:bank_account) { Fabricate(:bank_account_pay_method) }

    it 'fabricates' do
      expect(bank_account.stripe_id).to be_present
    end
  end

  describe 'Card' do
    subject(:card) { Fabricate(:card_pay_method) }

    it 'fabricates' do
      expect(card.stripe_id).to be_present
    end
  end
end
