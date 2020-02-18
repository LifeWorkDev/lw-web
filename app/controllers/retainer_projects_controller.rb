class RetainerProjectsController < ProjectsController
private

  def retainer_project_params
    params.require(:retainer_project).permit(:amount)
  end

  def set_project
    @project = current_entity.projects.retainer.find(params[:id])
  end
end
