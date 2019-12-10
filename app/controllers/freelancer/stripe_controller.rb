class Freelancer::StripeController < AuthenticatedController
  def connect; end

  def callback
    stripe_resp = nil
    safely do
      stripe_resp = Stripe::OAuth.token(grant_type: :authorization_code, code: params[:code])
    end
    if stripe_resp
      current_user.update!(stripe_id: stripe_resp.stripe_user_id, stripe_access_token: stripe_resp.access_token, stripe_key: stripe_resp.stripe_publishable_key, stripe_refresh_token: stripe_resp.refresh_token)
      redirect_to [:milestones, current_namespace, project], notice: 'Successfully linked to Stripe.'
    else
      redirect_to freelancer_stripe_connect_path, alert: 'Could not link to Stripe. Please try again.'
    end
  end
end
