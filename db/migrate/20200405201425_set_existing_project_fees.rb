class SetExistingProjectFees < ActiveRecord::Migration[6.0]
  def up
    Project.all.each do |proj|
      proj.fee_percent ||= LIFEWORK_FEE
      proj.save!
    end
  end

  def down
    Project.all.each do |proj|
      proj.update!(fee_percent: nil)
    end
  end
end
