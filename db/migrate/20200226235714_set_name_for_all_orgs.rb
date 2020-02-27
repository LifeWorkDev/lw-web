class SetNameForAllOrgs < ActiveRecord::Migration[6.0]
  def up
    Org.where(name: nil).each do |org|
      org.update!(name: org.primary_contact.name)
    end
  end
end
