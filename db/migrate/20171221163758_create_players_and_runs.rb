class CreatePlayersAndRuns < ActiveRecord::Migration[5.1]
  def change
    create_table :players do |t|
      t.string :name, null: false
      t.timestamp :paused_until
    end
    add_index :players, :name

    create_table :runs do |t|
      t.integer :player_id, null: false
      t.timestamp :ended_at
      t.integer :hearts_given
      t.timestamps
    end
    add_index :runs, [:player_id, :ended_at]
    add_foreign_key :runs, :players
  end
end
