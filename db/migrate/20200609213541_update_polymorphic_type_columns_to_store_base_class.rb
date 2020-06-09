class UpdatePolymorphicTypeColumnsToStoreBaseClass < ActiveRecord::Migration[6.0]
  def up
    FriendlyId::Slug.connection.execute("delete from friendly_id_slugs where id in (select min(id) from friendly_id_slugs group by slug, scope having count(*) > 1)")
    FriendlyId::Slug.where(sluggable_type: %w[MilestoneProject RetainerProject]).update_all(sluggable_type: "Project")
    Payment.where(pays_for_type: "RetainerProject").update_all(pays_for_type: "Project")
  end
end
