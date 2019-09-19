class ApplicationMailbox < ActionMailbox::Base
  # routing /something/i => :somewhere
  routing CommentRepliesMailbox::MATCHER => :comment_replies
  # routing /comments-(.+)@reply.lifeworkonline.com/i => :comment_replies
end
