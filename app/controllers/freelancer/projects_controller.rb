class Freelancer::ProjectsController < AuthenticatedController
  before_action :set_project, only: %i[show edit milestones payments update destroy]

  # GET /projects
  def index
    @projects = current_user.projects.all
  end

  # GET /projects/1
  def show; end

  # GET /projects/new
  def new
    # Convert to https://stackoverflow.com/a/45740056/337446
    @project = current_user.projects.build(type: MilestoneProject)
  end

  # GET /projects/1/edit
  def edit; end

  # POST /projects
  def create
    @project = current_user.projects.build(project_params(@project.type))

    if @project.save
      redirect_to @project, notice: 'Project was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /projects/1
  def update
    if @project.update(project_params)
      redirect_to freelancer_projects_path, notice: 'Project was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /projects/1
  def destroy
    @project.destroy
    redirect_to freelancer_projects_path, notice: 'Project was successfully destroyed.'
  end

private

  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = current_user.projects.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def project_params
    params.require(@project.type.underscore.to_sym).permit(:amount, :name, milestones_attributes: %i[amount date description id])
  end
end
