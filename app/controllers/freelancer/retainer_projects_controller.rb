class Freelancer::RetainerProjectsController < RetainerProjectsController
  include Freelancer::ProjectHelpers

  # GET /f/retainer_projects/1/payment
  def payment
    @heading = "Tell us how much you should get paid."
  end

  # PATCH/PUT /f/retainer_projects/1
  def update
    if @project.update(retainer_project_params)
      redirect_to [:preview, current_namespace, @project.becomes(Project)]
    else
      render :payment
    end
  end
end
