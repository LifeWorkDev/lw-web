require 'rails_helper'

RSpec.describe Freelancer::UsersController, type: :request do
  let(:user) { Fabricate(:user) }

  before { sign_in user }

  describe 'PATCH /f/user' do
    subject(:req) { patch freelancer_user_path, params: params }

    context 'when user is outside North America' do
      let(:params) { { 'user[time_zone]': ActiveSupport::TimeZone.non_us_zones.map(&:name).sample } }

      it { expect(req).to redirect_to(waitlist_freelancer_user_path) }
    end

    context 'when user is within North America' do
      let(:params) { { 'user[time_zone]': ActiveSupport::TimeZone.basic_us_zone_names.sample } }

      it { expect(req).to redirect_to(freelancer_stripe_connect_path) }
    end
  end
end
