class ApplicationMailer < ActionMailer::Base
  default from: Devise.mailer_sender
  default to: -> { @recipient.email }
  layout "mailer"

  before_action :set_params
  around_action :use_recipient_zone

  def self.inherited(subclass)
    # Structure views as mailers/name/template instead of name_mailer/template
    subclass.default template_path: "mailers/#{subclass.name.underscore.gsub("_mailer", "")}"
  end

private

  def set_params
    @payment = params[:payment]
    @milestone = params[:milestone] || @payment&.milestone
    @project = params[:project] || @milestone&.project || @payment&.project
    @recipient = params[:recipient]
    @refund_amount = Money.new(params[:refund_amount_cents], @payment.currency) if @payment
  end

  def use_recipient_zone
    Time.use_zone(@recipient&.time_zone) { yield }
  end
end
