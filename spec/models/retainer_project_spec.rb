require "rails_helper"

RSpec.describe RetainerProject, type: :model do
  subject(:project) { Fabricate(:retainer_project) }

  describe "#next_date" do
    it { expect(project.next_date.month).to eq project.start_date.month + 1 }
    it { expect(project.next_date.day).to be <= project.start_date.day }
  end
end
