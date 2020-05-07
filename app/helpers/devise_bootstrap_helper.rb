module DeviseBootstrapHelper
  def devise_bootstrap_error_messages!
    return "" if (resource.blank? || resource.errors.empty?) && flash[:alert].blank? && flash[:notice].blank?

    messages = resource.errors.full_messages.collect { |message| content_tag(:li, message.html_safe) }
    if flash[:alert].present?
      sentence = flash[:alert]
    elsif messages.any?
      message_tags = content_tag :ul, messages.join("\n").html_safe, class: "mt-1 mb-0"
      sentence = <<-HTML
      <strong>
        #{t(
          "errors.messages.not_saved",
          count: messages.size,
          resource: resource.class.model_name.human.downcase,
        )}
      </strong>
      HTML
    end

    html = ""

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
