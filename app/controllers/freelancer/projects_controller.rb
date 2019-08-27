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

  # GET /projects/1/milestones
  def milestones; end

  # GET /projects/1/payments
  def payments; end

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
    @project.assign_attributes(project_params)
    notice = "#{params[:button].capitalize} were updated." if @project.milestones_changed?
    if @project.save
      path = params[:button] == 'payments' ? freelancer_stripe_connect_path : payments_freelancer_project_path(@project)
      redirect_to path, notice: notice
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
    @project = current_user.projects.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def project_params
    params.require(@project.type.underscore.to_sym).permit(:amount, :name, milestones_attributes: %i[amount date description id])
  end
end
