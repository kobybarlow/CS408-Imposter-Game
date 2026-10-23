class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.references :category, null: false, foreign_key: true
      t.references :secret_word, null: true, foreign_key: { to_table: :words }
      t.string :status, null: false, default: "setup"
    end
  end
end
