class ApplicationMailbox < ActionMailbox::Base
  # routing /something/i => :somewhere
  routing CommentRepliesMailbox::MATCHER => :comment_replies
end
