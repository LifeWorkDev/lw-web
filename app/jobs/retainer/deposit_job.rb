module Retainer
  class DepositJob < Job
    def perform(retainer_project)
      super

      retainer_project.deposit!
    end
  end
end
