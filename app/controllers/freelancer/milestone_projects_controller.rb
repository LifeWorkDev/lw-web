module Freelancer
  class MilestoneProjectsController < ProjectsController
    before_action :set_project, only: %i[edit milestones payments update destroy]

    # GET /milestone_projects/new
    def new
      # Convert to https://stackoverflow.com/a/45740056/337446
      @project = current_user.projects.build(type: MilestoneProject)
    end

    # GET /milestone_projects/1/edit
    def edit; end

    # POST /milestone_projects
    def create
      @project = current_user.projects.build(project_params.merge(type: MilestoneProject))

      if @project.save
        redirect_to [:milestones, current_namespace, @project], notice: 'Project was successfully created.'
      else
        render :new
      end
    end

    # GET /milestone_projects/1/milestones
    def milestones; end

    # GET /milestone_projects/1/payments
    def payments
      @back = [:milestones, current_namespace, @project]
      @heading = 'Tell us how much you should get paid.'
    end

    # PATCH/PUT /milestone_projects/1
    def update
      @project.assign_attributes(project_params)
      notice = "#{params[:button].capitalize} were updated." if @project.milestones_changed?
      if @project.save
        path = params[:button] == 'payments' ? freelancer_stripe_connect_path : [:payments, current_namespace, @project]
        redirect_to path, notice: notice
      else
        render params[:button].to_sym
      end
    end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = current_user.projects.find(params[:id])
    end

    def project_params
      params.require(:milestone_project).permit(:name, :org_id)
    end
  end
end
