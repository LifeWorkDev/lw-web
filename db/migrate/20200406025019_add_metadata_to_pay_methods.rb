class AddMetadataToPayMethods < ActiveRecord::Migration[6.0]
  def up
    add_column :pay_methods, :metadata, :jsonb

    PayMethod.reset_column_information

    # Existing cards get grandfathered into 0 fees for now
    PayMethods::Card.all.each do |pm|
      pm.update!(fee_percent: 0)
    end
  end

  def down
    remove_column :pay_methods, :metadata
  end
end
