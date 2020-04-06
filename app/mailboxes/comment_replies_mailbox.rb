class CommentRepliesMailbox < ApplicationMailbox
  def process
    return if user.nil? || commentable.nil?

    return unless commentable.freelancer == user || commentable.client.users.include?(user)

    commentable.comments.create(commenter: user, comment: parsed_mail_body)
  end

  memoize def user
    User.find_by!(email: mail.from)
  end

  memoize def commentable
    commentable_class.find_by(id: commentable_id)
  end

  memoize def commentable_class
    matches[1].classify.constantize
  end

  memoize def commentable_id
    matches[2]
  end

  memoize def matches
    mail.recipients.each do |r|
      result = COMMENT_REPLIES_MATCHER.match r
      return result unless result.nil?
    end
  end
end
