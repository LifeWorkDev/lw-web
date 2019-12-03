class SetIntercomTags < ApplicationJob
  def perform(record)
    record.set_intercom_tags
  end
end
