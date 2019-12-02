module ActiveSupport
  class TimeZone
    class << self
      include Memery

      memoize def basic_us_zones
        TZInfo::Country.get('US').zone_identifiers.map do |tz_id|
          name = ActiveSupport::TimeZone::MAPPING.key(tz_id)
          name && ActiveSupport::TimeZone[name]
        end.compact.sort!
      end

      memoize def basic_us_zone_names
        basic_us_zones.map(&:name)
      end

      memoize def non_us_zones
        all - basic_us_zones
      end
    end
  end
end
