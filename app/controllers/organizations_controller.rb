class OrganizationsController < AuthenticatedController
  before_action :set_organization, only: %i[show edit update destroy]

  # GET /organizations
  def index
    @organizations = Organization.all
  end

  # GET /organizations/1
  def show; end

  # GET /organizations/new
  def new
    @organization = Organization.new
    @organization.projects.build(type: MilestoneProject)
    @organization.users.build
  end

  # GET /organizations/1/edit
  def edit; end

  # POST /organizations
  def create
    @organization = Organization.new(organization_params)

    if @organization.save
      redirect_to edit_project_path(@organization.projects.last), notice: 'Organization was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /organizations/1
  def update
    if @organization.update(organization_params)
      redirect_to @organization, notice: 'Organization was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /organizations/1
  def destroy
    @organization.destroy
    redirect_to organizations_url, notice: 'Organization was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_organization
    @organization = Organization.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def organization_params
    params.require(:organization).permit(:name, projects_attributes: :name, users_attributes: %i[name email]).to_h.deep_merge(projects_attributes: { '0': { type: MilestoneProject, user_id: current_user.id } })
  end
end
