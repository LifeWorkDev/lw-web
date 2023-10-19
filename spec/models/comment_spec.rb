require "rails_helper"

RSpec.describe Comment do
  subject(:comment) { Fabricate(:comment) }

  it { is_expected.to have_attribute(:comment) }
end
