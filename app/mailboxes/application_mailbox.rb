class ApplicationMailbox < ActionMailbox::Base
  COMMENT_REPLIES_MATCHER = /comments\-(\d+)@#{REPLIES_HOST}/i.freeze

  routing COMMENT_REPLIES_MATCHER => :comment_replies
end
