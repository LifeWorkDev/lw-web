class Fields::CollectionSelectWithLink < Trestle::Form::Fields::CollectionSelect
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::UrlHelper
  include Trestle::UrlHelper

  attr_reader :choices, :html_options

  def initialize(builder, template, name, collection, value_method, text_method, options = {}, html_options = {})
    super

    @choices = options_for_select(collection.map { |item| [item.send(text_method), item.send(value_method), { 'data-link' => admin_link_to('View', item, class: 'float-right mr-3') }] }, builder.object&.send(name))

    @html_options = default_html_options.merge(html_options)
  end

  def default_html_options
    Trestle::Options.new(class: ['form-control'], disabled: admin.readonly?, data: { enable_custom_select2: true })
  end

  def field
    builder.raw_select(name, choices, options, html_options)
  end
end
