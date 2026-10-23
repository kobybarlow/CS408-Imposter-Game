class CreateWords < ActiveRecord::Migration[8.1]
  def change
    create_table :words do |t|
      t.references :category, null: false, foreign_key: true
      t.string :word, null: false
    end

    add_index :words, [ :category_id, :word ], unique: true
  end
end
