class ApplicationMailbox < ActionMailbox::Base
  # routing /something/i => :somewhere
  routing /^comments\+\d\+\d@reply\./i => :comment_replies
end
