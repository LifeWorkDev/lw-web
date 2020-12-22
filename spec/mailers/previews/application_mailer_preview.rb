class ApplicationMailerPreview < ActionMailer::Preview
private

  def comment
    Comment.find_by(id: params[:id]) || Comment.sample
  end

  def milestone
    Milestone.find_by(id: params[:id]) || Milestone.deposited.sample
  end

  def milestone_project
    MilestoneProject.find_by(id: params[:id]) || MilestoneProject.not_pending.sample
  end

  def payment
    Payment.find_by(id: params[:id]) || Payment.where(status: %i[refunded partially_refunded]).sample
  end

  def retainer_project
    RetainerProject.find_by(id: params[:id]) || RetainerProject.not_pending.sample
  end
end
