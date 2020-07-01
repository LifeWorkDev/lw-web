class SetUserFeesFromZeroToNil < ActiveRecord::Migration[6.0]
  def up
    User.metadata_where(fee_percent: 0).update(fee_percent: nil)
  end

  def down
    User.jsonb_excludes(:metadata, :fee_percent).or(User.where(metadata: nil)).update(fee_percent: 0)
  end
end
