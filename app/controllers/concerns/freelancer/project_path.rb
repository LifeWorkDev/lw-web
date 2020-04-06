module Freelancer::ProjectPath
  extend ActiveSupport::Concern

  included do
    def project_path(project)
      if project.pending?
        if project.retainer?
          next_step(project)
        elsif project.client.pending? && project.client.projects.size <= 1
          [:edit, current_namespace, project.client]
        elsif project.contract_sent?
          next_step(project)
        else
          [:edit, current_namespace, project.becomes(Project)]
        end
      else
        [current_namespace, project.becomes(Project), :comments]
      end
    end
    helper_method :project_path
  end
end
