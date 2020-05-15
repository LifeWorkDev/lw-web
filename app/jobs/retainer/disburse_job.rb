module Retainer
  class DisburseJob < Job
    def perform(retainer_project)
      super

      retainer_project.disburse!
    end
  end
end
