class MilestoneProjectsController < ProjectsController
  # GET /milestone_projects/new
  def new
    @project = current_entity.projects.build(type: MilestoneProject)
  end

private

  def milestone_project_params
    params.require(:milestone_project).permit(:name, :amount, milestones_attributes: %i[amount date description id])
  end

  def set_project
    @project = current_entity.projects.milestone.find(params[:id])
  end
end
