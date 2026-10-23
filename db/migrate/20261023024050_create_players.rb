class CreatePlayers < ActiveRecord::Migration[8.1]
  def change
    create_table :players do |t|
      t.references :game, null: false, foreign_key: true
      t.string :name, null: false
      t.boolean :is_imposter, null: false, default: false
      t.integer :turn_order, null: false
    end

    add_index :players, [ :game_id, :turn_order ], unique: true
  end
end
