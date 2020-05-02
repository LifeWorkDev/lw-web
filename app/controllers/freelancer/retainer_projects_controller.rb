class Freelancer::RetainerProjectsController < RetainerProjectsController
  include Freelancer::ProjectPath

  # GET /f/retainer_projects/1/payment
  def payment
    @back = [:edit, current_namespace, @project.becomes(Project)]
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
