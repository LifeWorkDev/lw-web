class Users::SessionsController < Devise::SessionsController
  after_action :intercom_shutdown, only: :new
  after_action :prepare_intercom_shutdown, only: :destroy

protected

  def intercom_shutdown
    IntercomRails::ShutdownHelper.intercom_shutdown(session, cookies, request.domain)
  end

  def prepare_intercom_shutdown
    IntercomRails::ShutdownHelper.prepare_intercom_shutdown(session)
  end
end
