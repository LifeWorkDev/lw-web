class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include JsonbAccessor
  include JsonbAccessor::QueryBuilder
  include Memery
  include PgSearch::Model
  include StringEnum

  delegate :l, :t, to: I18n, private: true

  class << self
    include Memery

    delegate :fa_url, :mdi_url, to: "ApplicationController.helpers", private: true

    def callbacks_of_type(type, kind: :all)
      send("_#{type}_callbacks").select { |cb|
        [:all, cb.kind].include? kind
      }.map(&:filter)
    end

    def sample(limit = 1)
      result = order(Arel.sql("random()")).limit(limit)
      limit == 1 ? result.first : result
    end
  end

private

  def raise_subclass_should_override
    raise NotImplementedError, "Subclass should override method '#{caller_locations(1, 1)[0].label}'"
  end
end
