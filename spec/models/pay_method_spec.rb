require "rails_helper"

RSpec.describe PayMethod do
  let(:org) { Fabricate(:named_org) }

  it "activates the org" do
    expect { Fabricate(%i[bank_account_pay_method card_pay_method].sample, org: org) }.to change { org.status }.to("active")
  end
end
