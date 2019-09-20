class ApplicationMailbox < ActionMailbox::Base
  COMMENT_REPLIES_MATCHER = /comments-(.+)@reply.lifeworkonline.com/i.freeze

  routing COMMENT_REPLIES_MATCHER => :comment_replies
end
