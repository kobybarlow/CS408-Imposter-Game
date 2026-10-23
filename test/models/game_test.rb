require "test_helper"

class GameTest < ActiveSupport::TestCase
  setup do
    @category = Category.create!(name: "Food")
    @word = @category.words.create!(word: "Pizza")
  end

  test "new game defaults to setup and allows no secret word" do
    game = Game.new(category: @category)

    assert_equal "setup", game.status
    assert game.valid?
  end

  test "game requires a category" do
    game = Game.new

    assert_not game.valid?
    assert_includes game.errors[:category], "must exist"
  end

  test "game rejects an unknown status" do
    game = Game.new(category: @category, status: "unknown")

    assert_not game.valid?
    assert_includes game.errors[:status], "is not included in the list"
  end

  test "playing and completed games require a secret word" do
    [ "playing", "completed" ].each do |status|
      game = Game.new(category: @category, status: status)

      assert_not game.valid?
      assert_includes game.errors[:secret_word], "can't be blank"
    end
  end

  test "playing and completed games accept a word from their category" do
    [ "playing", "completed" ].each do |status|
      game = Game.new(
        category: @category,
        secret_word: @word,
        status: status
      )

      assert game.valid?
    end
  end

  test "secret word must belong to the selected category" do
    other_category = Category.create!(name: "Sports")
    other_word = other_category.words.create!(word: "Soccer")

    game = Game.new(
      category: @category,
      secret_word: other_word,
      status: "playing"
    )

    assert_not game.valid?
    assert_includes game.errors[:secret_word],
                    "must belong to the selected category"
  end
end
