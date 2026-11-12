class AddCluePositionToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :clue_position, :integer, default: 1, null: false
  end
end
