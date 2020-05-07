class ApplicationMailbox < ActionMailbox::Base
  include Memery

  COMMENT_REPLIES_MATCHER = /^comments\-(\w+)\-(\d+)@#{REPLIES_HOST}$/i.freeze

  routing COMMENT_REPLIES_MATCHER => :comment_replies

  memoize def parsed_mail_body
    body = if mail.multipart? && mail.text_part
      mail.text_part.body.decoded
    else
      mail.decoded
    end
    EmailReplyParser.parse_reply(body)
  end
end
