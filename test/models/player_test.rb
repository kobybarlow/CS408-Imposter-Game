require "test_helper"

class PlayerTest < ActiveSupport::TestCase
  setup do
    category = Category.create!(name: "Food")
    @game = Game.create!(category: category)
  end

  test "player with required information is valid" do
    player = @game.players.build(name: "Alex", turn_order: 1)

    assert player.valid?
    assert_equal false, player.is_imposter
  end

  test "player requires a name" do
    player = @game.players.build(name: "", turn_order: 1)

    assert_not player.valid?
    assert_includes player.errors[:name], "can't be blank"
  end

  test "player requires a game" do
    player = Player.new(name: "Alex", turn_order: 1)

    assert_not player.valid?
    assert_includes player.errors[:game], "must exist"
  end

  test "turn order must be a positive whole number" do
    [ nil, 0, -1, 1.5 ].each do |position|
      player = @game.players.build(
        name: "Alex",
        turn_order: position
      )

      assert_not player.valid?, "Turn order #{position.inspect} should be invalid"
    end
  end

  test "players in the same game cannot share a turn position" do
    @game.players.create!(name: "Alex", turn_order: 1)
    player = @game.players.build(name: "Blair", turn_order: 1)

    assert_not player.valid?
    assert_includes player.errors[:turn_order], "has already been taken"
  end

  test "different games can use the same turn position" do
    @game.players.create!(name: "Alex", turn_order: 1)
    other_game = Game.create!(category: @game.category)
    player = other_game.players.build(name: "Blair", turn_order: 1)

    assert player.valid?
  end

  test "imposter flag must be true or false" do
    player = @game.players.build(name: "Alex", turn_order: 1)

    player.is_imposter = true
    assert player.valid?

    player.is_imposter = false
    assert player.valid?

    player.is_imposter = nil
    assert_not player.valid?
    assert_includes player.errors[:is_imposter], "is not included in the list"
  end

  test "game returns players in turn order" do
    second = @game.players.create!(name: "Blair", turn_order: 2)
    first = @game.players.create!(name: "Alex", turn_order: 1)

    assert_equal [ first, second ], @game.players.reload.to_a
  end
end
