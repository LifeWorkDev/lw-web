class Client::RetainerProjectsController < RetainerProjectsController
  # GET /c/retainer_projects/1/payment
  def payment
    redirect_to [:deposit, current_namespace, @project.becomes(Project)]
  end
end
