class ProcessWebhook < ApplicationJob
  def perform(webhook)
    webhook.process!
  end
end
