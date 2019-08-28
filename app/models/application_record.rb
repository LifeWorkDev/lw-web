class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include JsonbAccessor
  include JsonbAccessor::QueryBuilder
  include StringEnum

  def self.callbacks_of_type(type, kind: :all)
    send("_#{type}_callbacks").select do |cb|
      [:all, cb.kind].include? kind
    end.map(&:filter)
  end

private

  def raise_subclass_should_override
    raise NotImplementedError, "Subclass should override method '#{caller_locations(1, 1)[0].label}'"
  end
end
