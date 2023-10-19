class AuthenticatedController < ApplicationController
  include SetLogidzeResponsible

  around_action :set_time_zone
  prepend_before_action :authenticate_user!, except: :home
  protect_from_forgery prepend: true, with: :reset_session

  def current_org
    current_user.org
  end
  helper_method :current_org

  def current_entity
    client_namespace? ? current_org : current_user
  end
  helper_method :current_entity

  def home
    if user_signed_in?
      redirect_to user_default_path
    else
      redirect_to "/login"
    end
  end

private

  def set_time_zone
    Time.use_zone(current_user&.time_zone) { yield }
  end

  def user_default_path
    if current_user.time_zone.present?
      current_entity = current_user.org || current_user
      if current_user.client? && current_user.org.work_frequency.blank?
        edit_client_org_path
      elsif current_user.finished_onboarding?
        [current_user.type, Project] # Dashboard
      elsif current_user.freelancer?
        if current_user.projects.size == 1
          [current_user.type, current_entity.projects.first.becomes(Project)]
        else
          new_freelancer_org_path
        end
      elsif current_org.projects.client_invited.any?
        [current_user.type, current_entity.projects.client_invited.last.becomes(Project)]
      else
        [current_user.type, Project] # Dashboard
      end
    elsif current_user.freelancer?
      edit_freelancer_user_path
    else
      edit_user_path
    end
  end

  class Forbidden < StandardError; end
end
