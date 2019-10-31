module Client
  class BankAccountsController < PayMethodsController
    before_action :set_pay_method, only: %i[show edit update destroy]

    # GET /pay_methods
    def index
      @pay_methods = current_org.pay_methods
      redirect_to new_client_pay_method_path if @pay_methods.blank?
    end

    # GET /pay_methods/1
    def show; end

    # GET /pay_methods/new
    def new
      @pay_method = current_org.pay_methods.build(type: PayMethods::BankAccount)
    end

    # GET /pay_methods/1/edit
    def edit; end

    # POST /pay_methods
    def create
      @pay_method = current_org.pay_methods.build(pay_method_params.merge(created_by: current_user))

      if @pay_method.save
        render json: { message: 'Pay method successfully updated.' }
      else
        render json: { error: @pay_method.errors.full_messages.join(', ') }, status: 400
      end
    end

    # PATCH/PUT /pay_methods/1
    def update
      if @pay_method.update(pay_method_params)
        redirect_to [current_namespace, @pay_method], notice: 'Pay method was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /pay_methods/1
    def destroy
      @pay_method.destroy
      redirect_to [current_namespace, PayMethod], notice: 'Pay method was successfully destroyed.'
    end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_pay_method
      @pay_method = current_org.pay_methods.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def pay_method_params
      params.require(:bank_account).permit(:type, :name, :issuer, :kind, :last_4, :exp_month, :exp_year, :plaid_account_id, :plaid_link_token)
    end
  end
end
