module Freelancer::ProjectHelpers
  extend ActiveSupport::Concern

  included do
    def after_create_or_update_path(project)
      if project.milestone?
        [:milestones, current_namespace, project]
      elsif project.retainer?
        [:payment, current_namespace, project]
      end
    end
    helper_method :after_create_or_update_path

    def edit_path(project)
      [:edit, current_namespace, project.client.primary_contact.active? ? project.becomes(Project) : project.client]
    end
    helper_method :edit_path

    def next_step(project)
      if project.may_invite_client?
        if current_user.stripe_id.present?
          after_create_or_update_path(project)
        else
          freelancer_stripe_connect_path
        end
      else
        [:status, current_namespace, project.becomes(Project)]
      end
    end
    helper_method :next_step

    def project_path(project)
      if project.pending?
        if project.contract_sent?
          next_step(project)
        else
          edit_path(project)
        end
      else
        [:timeline, current_namespace, project.becomes(Project)]
      end
    end
    helper_method :project_path
  end
end
