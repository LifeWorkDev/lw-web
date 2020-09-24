class Client::ProjectsController < ProjectsController
  def activate
    @project.activate! if @project.may_activate?
    redirect_to [current_namespace, Project], notice: "Your project with #{@project.freelancer} is good to go! We'll notify you on #{l(@project.start_date, format: :text_without_year)} when the first deposit is withdrawn."
  end

  def deposit
    template = "client/#{@project.type.underscore.pluralize}/deposit"
    @add_pay_method = "/c/pay_methods?project=#{@project.slug}"
    if request.post?
      if @project.deposit!(current_user)
        redirect_to [current_namespace, Project], notice: "Your deposit was received. #{@project.freelancer} has been notified so they can start work on your project."
      else
        @payment_error = @project.payments.last.note
        render template, status: :unprocessable_entity
      end
    elsif current_org.primary_pay_method
      render template
    else
      flash.keep :notice
      redirect_to @add_pay_method
    end
  end

  def index
    @projects = current_entity.projects.not_archived.not_pending.order(:name) + current_entity.projects.archived.order(:name)
  end

  def show
    redirect_to project_path(@project)
  end

  def project_path(project)
    project.client_invited? ? [:deposit, current_namespace, project.becomes(Project)] : [:timeline, current_namespace, project.becomes(Project)]
  end
  helper_method :project_path
end
