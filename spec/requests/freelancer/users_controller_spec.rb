require "rails_helper"

RSpec.describe Freelancer::UsersController, type: :request do
  let(:user) { Fabricate(:user) }

  before { sign_in user }

  describe "PATCH /f/user" do
    subject(:req) { patch freelancer_user_path, params: params }

    let(:params) { {'user[time_zone]': time_zone} }
    let(:time_zone) { ActiveSupport::TimeZone.basic_us_zone_names.sample }

    context "when user is outside North America" do
      let(:time_zone) { ActiveSupport::TimeZone.non_us_zones.map(&:name).sample }

      it { expect(req).to redirect_to(waitlist_freelancer_user_path) }
    end

    context "when user is within North America" do
      it { expect(req).to redirect_to(freelancer_content_walkthrough_path) }
    end

    context "when client is provided" do
      let(:user) { Fabricate(:freelancer) }
      let(:client) { user.clients.first }

      before { params.merge!(client: client.slug) }

      it { expect(req).to redirect_to(edit_freelancer_org_path(client)) }
    end
  end
end
