class ProjectsController < AuthenticatedController
  before_action :set_project, if: -> { params[:id].present? }

  # GET /projects
  def index
    @projects = current_entity.projects
  end

  # GET /projects/1
  def show
    redirect_to project_path(@project)
  end

  # GET /projects/1/edit
  def edit; end

  # GET /projects/new
  def new
    @project = current_entity.projects.build
  end

  # POST /projects
  def create
    @project = current_entity.projects.build(project_params)

    if @project.save
      redirect_to next_step(@project), notice: 'Project was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /projects/1
  def update
    if @project.becomes(Project).update(project_params)
      redirect_to next_step(@project)
    else
      render :edit
    end
  end

  # DELETE /projects/1
  def destroy
    @project.destroy
    redirect_to [current_namespace, Project], notice: 'Project was successfully destroyed.'
  end

private

  def project_params
    params.require(:project).permit(:name, :org_id, :type, :status)
  end

  def set_project
    @project = current_entity.projects.find(params[:id])
  end
end
