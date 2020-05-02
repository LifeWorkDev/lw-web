class Client::ProjectsController < ProjectsController
  def deposit
    if request.post?
      @project.deposit!(current_user)
      redirect_to [current_namespace, Project], notice: "Your deposit was received. #{@project.freelancer.name} has been notified so they can start work on your project."
    elsif current_org.primary_pay_method
      render "client/#{@project.type.underscore.pluralize}/deposit"
    else
      flash.keep :notice
      redirect_to "/c/pay_methods?project=#{@project.slug}"
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
