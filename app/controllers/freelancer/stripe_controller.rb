class Freelancer::StripeController < AuthenticatedController
  def connect; end

  def callback
    stripe_resp = nil
    safely do
      stripe_resp = Stripe::OAuth.token(grant_type: :authorization_code, code: params[:code])
    end
    if stripe_resp
      current_user.update!(stripe_id: stripe_resp.stripe_user_id, stripe_access_token: stripe_resp.access_token, stripe_key: stripe_resp.stripe_publishable_key, stripe_refresh_token: stripe_resp.refresh_token)
      redirect = if (project = current_user.projects.first)
                   next_step(project)
                 else
                   user_default_path
                 end
      redirect_to redirect, notice: "Successfully linked to Stripe."
    else
      redirect_to freelancer_stripe_connect_path, alert: "Could not link to Stripe. Please try again."
    end
  end

  def dashboard
    redirect_to current_user.stripe_dashboard
  end
end
