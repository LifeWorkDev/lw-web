module Helpers::TrestleHelper
  def admin_auto_link_to(record)
    return if record.blank?

    admin_link_to(record, record)
  end
end
