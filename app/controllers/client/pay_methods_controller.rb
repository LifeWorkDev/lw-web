class Client::PayMethodsController < AuthenticatedController
  before_action :set_pay_method, only: %i[show edit update destroy]

  def created
    redirect_to client_projects_path, notice: "Payment method was successfully changed."
  end

  # GET /pay_methods
  def index
    # @pay_methods = current_org.pay_methods
  end

  # GET /pay_methods/1
  def show
  end

  # GET /pay_methods/new
  def new
    @intent = Stripe::SetupIntent.create if params[:type] == "cards"
    render "client/pay_methods/#{params[:type]}/new"
  end

  # GET /pay_methods/1/edit
  def edit
  end

  # POST /pay_methods
  def create
    @pay_method = current_org.pay_methods.build(pay_method_params.merge(created_by: current_user))

    if @pay_method.save
      location = if params[:project].present?
        deposit_client_project_path(params[:project], new_pay_method: true)
      else
        created_client_pay_methods_path
      end
      render json: {location: location}
    else
      render json: {error: @pay_method.errors.full_messages.join(", ")}, status: 400
    end
  end

  # PATCH/PUT /pay_methods/1
  def update
    if @pay_method.update(pay_method_params)
      redirect_to [current_namespace, @pay_method], notice: "Payment method was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /pay_methods/1
  def destroy
    @pay_method.destroy
    redirect_to [current_namespace, PayMethod], notice: "Pay method was successfully destroyed."
  end

private

  # Use callbacks to share common setup or constraints between actions.
  def set_pay_method
    @pay_method = current_org.pay_methods.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def pay_method_params
    params.require(:pay_method).permit(:type, :name, :issuer, :kind, :last_4, :exp_month, :exp_year, :plaid_id, :plaid_link_token, :stripe_id)
  end
end
