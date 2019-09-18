class ClientMailerPreview < ActionMailer::Preview
  def invite
    ClientMailer.invite(user: User.first, project: Project.first)
  end
end
