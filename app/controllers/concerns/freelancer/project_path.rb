module Freelancer::ProjectPath
  extend ActiveSupport::Concern

  included do
    def project_path(project)
      if project.pending?
        if project.client.pending?
          [:edit, current_namespace, project.client]
        else
          [:edit, current_namespace, project]
        end
      else
        [current_namespace, project, :comments]
      end
    end
    helper_method :project_path
  end
end
