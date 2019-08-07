class OrgsController < AuthenticatedController
  before_action :set_org, only: %i[show edit update destroy]

  # GET /orgs
  def index
    @orgs = Org.all
  end

  # GET /orgs/1
  def show; end

  # GET /orgs/new
  def new
    @org = Org.new
    @org.projects.build(type: MilestoneProject)
    @org.users.build
  end

  # GET /orgs/1/edit
  def edit; end

  # POST /orgs
  def create
    @org = Org.new(org_params)
    @org.current_user = current_user

    if @org.save
      redirect_to edit_project_path(@org.projects.last), notice: 'Org was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /orgs/1
  def update
    if @org.update(org_params)
      redirect_to edit_project_path(@org.projects.last), notice: 'Org was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /orgs/1
  def destroy
    @org.destroy
    redirect_to orgs_url, notice: 'Org was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_org
    @org = Org.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def org_params
    params.require(:org).permit(:name, projects_attributes: %i[id name], users_attributes: %i[id name email]).to_h.deep_merge(projects_attributes: { '0': { type: MilestoneProject, user_id: current_user.id } })
  end
end
