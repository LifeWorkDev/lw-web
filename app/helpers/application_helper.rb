module ApplicationHelper
  include Memery

  memoize def fa_svg(icon, options = {})
    svg_inject(fa_url(icon), options)
  end

  memoize def fa_url(icon)
    "https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@5.13.0/svgs/#{icon}.svg"
  end

  memoize def mdi_svg(icon, options = {})
    svg_inject(mdi_url(icon), options)
  end

  memoize def mdi_url(icon)
    "https://cdn.jsdelivr.net/npm/@mdi/svg@5.0.45/svg/#{icon}.svg"
  end

  memoize def svg_inject(url, options = {})
    options[:width] ||= options[:height] ||= options.delete(:size) || 24
    image_tag url, options.merge(onload: 'SVGInject(this)')
  end
end
