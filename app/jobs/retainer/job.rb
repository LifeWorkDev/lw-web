class Retainer::Job < ApplicationJob
  def perform(retainer_project)
    raise "Not a retainer project" unless retainer_project.is_a? RetainerProject
  end
end
