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
      redirect_to "/sign_up"
    end
  end

private

  def next_step(project)
    if project.may_invite_client?
      if current_user.stripe_id.present?
        if project.milestone?
          [:milestones, current_namespace, project]
        elsif project.retainer?
          [:preview, current_namespace, project.becomes(Project)]
        end
      else
        freelancer_stripe_connect_path
      end
    else
      [:status, current_namespace, project.becomes(Project)]
    end
  end

  def set_time_zone
    Time.use_zone(current_user&.time_zone) { yield }
  end

  def user_default_path
    if current_user.time_zone.present?
      current_entity = current_user.org || current_user
      if current_user.client? && current_user.org.work_frequency.blank?
        edit_client_org_path
      elsif current_user.finished_onboarding?
        [current_user.type, Project]
      elsif current_entity.projects.size == 1
        [current_user.type, current_entity.projects.first.becomes(Project)]
      elsif current_user.freelancer?
        new_freelancer_org_path
      end
    elsif current_user.freelancer?
      edit_freelancer_user_path
    else
      edit_user_path
    end
  end

  class Forbidden < StandardError; end
end
