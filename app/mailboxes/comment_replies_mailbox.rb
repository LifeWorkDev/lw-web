class CommentRepliesMailbox < ApplicationMailbox
  def process
    return if user.nil? || milestone.nil?

    return unless milestone.freelancer == user || milestone.client.users.include?(user)

    milestone.comments.create(commenter: user, comment: parsed_mail_body)
  end

  memoize def user
    User.find_by(email: mail.from)
  end

  memoize def milestone
    Milestone.find_by(id: milestone_id)
  end

  memoize def milestone_id
    recipient = mail.recipients.find { |r| COMMENT_REPLIES_MATCHER.match?(r) }
    recipient[COMMENT_REPLIES_MATCHER, 1]
  end
end
