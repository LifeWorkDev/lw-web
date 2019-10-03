class CommentRepliesMailbox < ApplicationMailbox
  def process
    return if user.nil? || milestone.nil?

    return unless milestone.project.freelancer == user || milestone.project.client.users.include?(user)

    milestone.comments.create(commenter: user, comment: parsed_mail_body)
  end

  def user
    @user ||= User.find_by(email: mail.from)
  end

  def milestone
    @milestone ||= Milestone.find_by(id: milestone_id)
  end

  def milestone_id
    recipient = mail.recipients.find { |r| COMMENT_REPLIES_MATCHER.match?(r) }
    recipient[COMMENT_REPLIES_MATCHER, 1]
  end
end
