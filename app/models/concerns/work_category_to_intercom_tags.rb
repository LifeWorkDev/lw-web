module WorkCategoryToIntercomTags
  extend ActiveSupport::Concern

  included do
    after_update_commit -> { SetIntercomTags.perform_later(self) }, if: :saved_change_to_work_category?

    def set_intercom_tags
      return false unless (token = Rails.application.credentials.intercom&.dig(:token))

      intercom = Intercom::Client.new(token: token)

      work_category&.each do |category|
        intercom.tags.tag(name: category, **intercom_metadata)
      end

      (WORK_CATEGORIES - work_category).each do |category|
        intercom.tags.untag(name: category, **intercom_metadata)
      end

      true
    end
  end
end
