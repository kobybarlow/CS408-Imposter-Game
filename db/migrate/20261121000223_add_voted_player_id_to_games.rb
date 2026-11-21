class AddVotedPlayerIdToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :voted_player_id, :integer
  end
end
