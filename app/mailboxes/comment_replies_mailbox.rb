class CommentRepliesMailbox < ApplicationMailbox
  MATCHER = /comments-(.+)@reply.lifeworkonline.com/i.freeze

  def process
    return if user.nil? || milestone.nil?

    milestone.comments.create(commenter: user, comment: comment)
  end

  def comment
    if mail.multipart? && mail.html_part
      document = Nokogiri::HTML(mail.html_part.body.decoded)
      document.at_css('body').inner_html.encode('utf-8')
    elsif mail.multipart? && mail.text_part
      mail.text_part.body.decoded
    else
      mail.decoded
    end
  end

  def user
    @user ||= User.find_by(email: mail.from)
  end

  def milestone
    @milestone ||= Milestone.find milestone_id
  end

  def milestone_id
    recipient = mail.recipients.find { |r| MATCHER.match?(r) }
    recipient[MATCHER, 1]
  end
end
