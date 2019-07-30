module SetLogidzeResponsible
  extend ActiveSupport::Concern

  included do
    around_action :set_logidze_responsible, unless: -> { request.get? }
  end

private

  def set_logidze_responsible(&block)
    Logidze.with_responsible(current_user&.id, &block)
  end
end
