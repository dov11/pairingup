class AddPairingDateToMatches < ActiveRecord::Migration[5.1]
  def change
    add_column :matches, :pairing_date, :datetime
  end
end
