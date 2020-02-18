class Freelancer::OrgsController < AuthenticatedController
  before_action :set_org, only: %i[show edit update destroy]

  # GET /orgs
  def index
    @clients = current_user.clients
  end

  # GET /orgs/1
  def show; end

  # GET /orgs/new
  def new
    @org = Org.new
    @org.projects.build
    @org.users.build
  end

  # GET /orgs/1/edit
  def edit; end

  # POST /orgs
  def create
    @org = Org.new(org_params.to_h.deep_merge(
                     projects_attributes: { '0': {
                       user_id: current_user.id,
                     } },
                     users_attributes: { '0': {
                       invited_by: current_user,
                     } },
                   ))

    if @org.save
      redirect_to next_step(@org.projects.last), notice: 'Client was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /orgs/1
  def update
    if @org.update(org_params)
      notice = 'Client was successfully updated.' if @org.changed?
      redirect_to next_step(@org.projects.last), notice: notice
    else
      render :edit
    end
  end

  # DELETE /orgs/1
  def destroy
    @org.destroy
    redirect_to orgs_url, notice: 'Client was successfully destroyed.'
  end

private

  # Use callbacks to share common setup or constraints between actions.
  def set_org
    @org = current_user.clients.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def org_params
    params.require(:org).permit(:name, projects_attributes: %i[id name status type], users_attributes: %i[id name email])
  end
end
