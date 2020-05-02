class ApplicationMailer < ActionMailer::Base
  default from: Devise.mailer_sender
  default to: -> { @recipient.email }
  layout "mailer"

  before_action :set_params
  around_action :use_recipient_zone

  def self.inherited(subclass)
    # Structure views as mailers/name/template instead of name_mailer/template
    subclass.default template_path: "mailers/#{subclass.name.underscore.gsub('_mailer', '')}"
  end

private

  def set_params
    @milestone = params[:milestone]
    @project = params[:project]
    @recipient = params[:recipient]
  end

  def use_recipient_zone
    Time.use_zone(@recipient&.time_zone) { yield }
  end
end
