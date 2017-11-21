class AddDefaultValueToPairingDateAttribute < ActiveRecord::Migration[5.1]
  def change
    def up
      change_column :matches, :pairing_date, :datetime, default: DateTime.now
    end

    def down
      change_column :matches, :pairing_date, :datetime, default: nil
    end
  end
end
