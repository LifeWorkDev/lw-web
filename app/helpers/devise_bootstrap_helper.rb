module DeviseBootstrapHelper
  def devise_bootstrap_error_messages!
    return '' if (resource.blank? || resource.errors.empty?) && flash[:alert].blank? && flash[:notice].blank?

    messages = resource.errors.full_messages.collect { |message| content_tag(:li, message.html_safe) }
    if flash[:alert].present?
      sentence = flash[:alert]
      sentence += '<br><br>This is a demo server. All linked bank accounts & payments are fake, but emails are actually sent, so please make sure to <strong>only use email addresses that are yours.</strong>' if sentence == t('devise.failure.unauthenticated') && !Rails.env.production?
    elsif messages.any?
      message_tags = content_tag :ul, messages.join("\n").html_safe, class: 'mt-1 mb-0'
      sentence = <<-HTML
      <strong>
        #{I18n.t(
          'errors.messages.not_saved',
          count: messages.size,
          resource: resource.class.model_name.human.downcase,
        )}
      </strong>
      HTML
    end

    html = ''

    if sentence
      html << <<-HTML
      <div class="alert alert-danger">
        <p class="alert-heading mb-0">#{sentence}</p>
        #{message_tags}
      </div>
      HTML
    end

    if flash[:notice].present?
      html << <<-HTML
      <div class="alert alert-success">
        <p class="alert-heading mb-0">#{flash[:notice]}</p>
      </div>
      HTML
    end

    html.html_safe
  end
end
