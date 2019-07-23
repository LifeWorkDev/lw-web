# frozen_string_literal: true

class AuthenticatedController < ApplicationController
  prepend_before_action :authenticate_user!
  protect_from_forgery prepend: true, with: :reset_session

  class Forbidden < StandardError; end
end
