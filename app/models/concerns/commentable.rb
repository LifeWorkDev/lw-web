module Commentable
  extend ActiveSupport::Concern

  included do
    has_many :comments, -> { order(:created_at) }, as: :commentable, inverse_of: :commentable, dependent: :destroy

    memoize def comment_reply_address
      "comments-#{self.class.to_s.underscore}-#{id}@#{REPLIES_HOST}"
    end
  end
end
