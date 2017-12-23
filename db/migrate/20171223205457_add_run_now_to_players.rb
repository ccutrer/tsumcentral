class AddRunNowToPlayers < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :run_now, :boolean, default: false, null: false
  end
end
