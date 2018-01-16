class AddExtendTimeoutToPlayer < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :extend_timeout, :boolean, default: false, null: false
  end
end
