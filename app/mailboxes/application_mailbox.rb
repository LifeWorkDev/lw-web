class ApplicationMailbox < ActionMailbox::Base
  COMMENT_REPLIES_MATCHER = /comments\-(\d+)@#{REPLIES_HOST}/i.freeze

  routing COMMENT_REPLIES_MATCHER => :comment_replies

  def parsed_mail_body
    body = if mail.multipart? && mail.text_part
             mail.text_part.body.decoded
           else
             mail.decoded
           end
    EmailReplyParser.parse_reply(body)
  end
end
