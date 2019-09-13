class Freelancer::MilestoneProjectsController < MilestoneProjectsController
  # GET /milestone_projects/1/milestones
  def milestones; end

  # GET /milestone_projects/1/payments
  def payments
    @back = [:milestones, current_namespace, @project]
    @heading = 'Tell us how much you should get paid.'
  end

  # PATCH/PUT /milestone_projects/1
  def update
    if params[:update_type].present? && params[:update_type] == 'dates'
      milestone_dates = milestone_project_params['milestones_attributes'].map { |milestone_param| milestone_param['date'] }
      @project.milestones.each do |milestone|
        date_string = milestone.date.to_s.split(' ').first
        @project.milestones.delete(milestone) unless milestone_dates.include?(date_string)
      end
    end

    @project.assign_attributes(milestone_project_params)
    if params[:button].present?
      notice = "#{params[:button].capitalize} were updated." if @project.milestones_changed?
      path = params[:button] == 'payments' ? freelancer_stripe_connect_path : [:payments, current_namespace, @project]
    else
      notice = 'Project was successfully updated.'
      path = [:milestones, current_namespace, @project]
    end
    if @project.save
      redirect_to path, notice: notice
    else
      render params[:button].to_sym
    end
  end
end
