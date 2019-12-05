class Freelancer::ProjectsController < ProjectsController
  def status
    return if request.get?

    @project.update(status: params[:button])
    redirect_to [current_namespace, Project], notice: "We're sorry to hear that. Feel free to reach out and we'll see if we can help!" if @project.proposal_rejected?
    redirect_to [:milestones, current_namespace, @project], notice: 'Congratulations on getting your contract out!' if @project.contract_sent?
  end
end
