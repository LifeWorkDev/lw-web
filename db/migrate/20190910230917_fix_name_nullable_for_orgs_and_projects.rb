class FixNameNullableForOrgsAndProjects < ActiveRecord::Migration[6.0]
  def change
    change_column_null(:orgs, :name, true)
    change_column_null(:projects, :name, false)
  end
end
