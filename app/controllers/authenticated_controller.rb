class AuthenticatedController < ApplicationController
  prepend_before_action :authenticate_user!

  def about_you; end

  def milestones; end

  def new_client; end

  class Forbidden < StandardError; end
end
