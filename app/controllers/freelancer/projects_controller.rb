class Freelancer::ProjectsController < ProjectsController
  def status
    return if request.get?

    @project.update(status: params[:button])
    redirect_to [current_namespace, Project], notice: "We're sorry to hear that. Feel free to reach out and we'll see if we can help!" if @project.proposal_rejected?
    redirect_to next_step(@project), notice: 'Congratulations on getting your contract out!' if @project.contract_sent?
  end

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
