module ApplicationHelper
  def mdi_svg(icon, options = {})
    options[:width] ||= 24
    content_tag(:svg, options.merge(viewBox: '0 0 24 24')) do
      content_tag(:use, nil, href: "#{asset_pack_path("media/svg/#{icon}.svg")}#mdi-#{icon}")
    end
  end
end
