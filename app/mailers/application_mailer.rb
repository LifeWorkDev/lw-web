class ApplicationMailer < ActionMailer::Base
  default from: Devise.mailer_sender
  layout 'mailer'

  def self.inherited(subclass)
    # Structure views as mailers/name/template instead of name_mailer/template
    subclass.default template_path: "mailers/#{subclass.name.underscore.gsub('_mailer', '')}"
  end
end
