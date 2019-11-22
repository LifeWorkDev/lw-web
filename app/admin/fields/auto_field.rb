class Fields::AutoField < Trestle::Form::Fields::StaticField
  include ActionView::Helpers::UrlHelper
  include Trestle::UrlHelper

  def initialize(builder, template, name, value = nil, options = {}, &block)
    value ||= builder.object.send(name) if builder.object
    value = I18n.l(value) if value.respond_to?(:strftime) # Date/Time
    value = admin_link_to(value, value) if value.is_a? ApplicationRecord
    super
  end
end
