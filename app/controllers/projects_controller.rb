class ProjectsController < AuthenticatedController
  before_action :set_project, if: -> { params[:id].present? }

  # GET /projects
  def index
    @projects = current_entity.projects.all
  end

  # GET /projects/1
  def show; end

  # GET /projects/1/edit
  def edit; end

  # POST /projects
  def create
    @project = current_entity.projects.build(project_params)

    if @project.save
      redirect_to @project, notice: 'Project was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /projects/1
  def update
    if @project.update(project_params)
      redirect_to [current_namespace, Project], notice: 'Project was successfully updated.'
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

  def current_entity
    current_namespace == 'client' ? current_org : current_user
  end

  def project_params
    params.require(@project.type.underscore.to_sym).permit(:amount, :name)
  end

  def set_project
    @project = current_entity.projects.find(params[:id])
  end
end
