class Client::ProjectsController < ProjectsController
  def deposit
    if request.post?
      @project.deposit!
      redirect_to [current_namespace, Project], notice: "Your deposit was received. #{@project.freelancer.name} has been notified so they can start work on your project."
    elsif current_org.primary_pay_method
      render "client/#{@project.type.underscore.pluralize}/deposit"
    else
      flash.keep :notice
      redirect_to "/c/pay_methods?project=#{@project.slug}"
    end
  end
end
