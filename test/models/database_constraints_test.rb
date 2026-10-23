require "test_helper"

class DatabaseConstraintsTest < ActiveSupport::TestCase
  setup do
    @category = Category.create!(name: "Food")
    @game = Game.create!(category: @category)
  end

  test "database prevents duplicate category names" do
    assert_raises ActiveRecord::RecordNotUnique do
      Category.insert_all!([
        { name: "Food", description: "Duplicate category" }
      ])
    end
  end

  test "database prevents duplicate turn positions within a game" do
    @game.players.create!(name: "Alex", turn_order: 1)

    assert_raises ActiveRecord::RecordNotUnique do
      Player.insert_all!([
        {
          game_id: @game.id,
          name: "Blair",
          turn_order: 1,
          is_imposter: false
        }
      ])
    end
  end
end
