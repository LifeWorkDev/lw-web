module Helpers::TrestleHelper
  def admin_auto_link_to(record)
    admin_link_to(record, record)
  end
end
