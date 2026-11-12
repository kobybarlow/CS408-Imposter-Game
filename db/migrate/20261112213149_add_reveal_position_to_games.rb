class AddRevealPositionToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :reveal_position, :integer, default: 1, null: false
  end
end
