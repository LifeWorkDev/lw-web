class ProjectsController < AuthenticatedController
  before_action :set_project, only: %i[show edit milestones payments update destroy]

  # GET /projects
  def index
    @projects = Project.all
  end

  # GET /projects/1
  def show; end

  # GET /projects/new
  def new
    @project = Project.new
    # Convert to https://stackoverflow.com/a/45740056/337446
    @project.type = MilestoneProject
  end

  # GET /projects/1/edit
  def edit; end

  # GET /projects/1/milestones
  def milestones; end

  # GET /projects/1/payments
  def payments; end

  # POST /projects
  def create
    @project = Project.new(project_params(@project.type))

    if @project.save
      redirect_to @project, notice: 'Project was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /projects/1
  def update
    if @project.update(project_params(@project.type))
      redirect_to payments_project_path(@project), notice: 'Milestones successfully added.' if params[:button] == 'milestones'
    else
      render params[:button].to_sym
    end
  end

  # DELETE /projects/1
  def destroy
    @project.destroy
    redirect_to projects_url, notice: 'Project was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = Project.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def project_params(type)
    params.require(type.underscore.to_sym).permit(:amount, :name, milestones_attributes: %i[amount date description id])
  end
end
