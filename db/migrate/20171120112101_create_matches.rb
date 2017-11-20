class CreateMatches < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    create_table :matches do |t|
      t.hstore :pairing

      t.timestamps
    end
  end
end
