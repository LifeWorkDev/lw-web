require 'rails_helper'

RSpec.describe Comment, type: :model do
  subject(:comment) { Fabricate(:comment) }

  it 'fabricates' do
    expect(comment.comment).to be_present
  end
end
