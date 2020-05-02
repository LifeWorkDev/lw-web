require "rails_helper"

RSpec.describe Comment, type: :model do
  subject(:comment) { Fabricate(:comment) }

  it { is_expected.to have_attribute(:comment) }
end
