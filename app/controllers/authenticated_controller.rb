class AuthenticatedController < ApplicationController
  prepend_before_action :authenticate_user!

  class Forbidden < StandardError; end
end
