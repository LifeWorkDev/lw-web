class MilestoneProjectsController < ProjectsController
private

  def milestone_project_params
    params.require(:milestone_project).permit(:name, :amount, :status, milestones_attributes: %i[amount date description id _destroy])
  end

  def project_type
    MilestoneProject
  end

  def set_project
    @project = current_entity.projects.milestone.find(params[:id])
  end
end
