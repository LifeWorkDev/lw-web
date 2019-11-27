module ApplicationHelper
  def mdi_svg(icon, options = {})
    options[:width] ||= options[:height] ||= options.delete(:size) || 24
    image_tag "https://cdn.jsdelivr.net/npm/@mdi/svg@4.6.95/svg/#{icon}.svg", options.merge(onload: 'SVGInject(this)')
  end
end
