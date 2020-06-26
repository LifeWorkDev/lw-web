class Fields::AutoField < Trestle::Form::Fields::StaticField
  include ActionView::Helpers::UrlHelper
  include Trestle::UrlHelper

  def initialize(builder, template, name, options = {})
    super(builder, template, name, nil, options)
  end

  def render
    default_value.blank? ? nil : super
  end

private

  def default_value
    value = super
    value = I18n.l(value) if value.respond_to?(:strftime) # Date/Time
    value = admin_link_to(value, value) if value.is_a? ApplicationRecord
    value = value.format if value.is_a? Money
    value
  end
end
