require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @category = Category.create!(name: "Setup Test Category")
    @category.words.create!(word: "Test Pizza")
    @category.words.create!(word: "Test Tacos")
  end

  test "setup page loads" do
    get new_game_path

    assert_response :success
    assert_select "form"
    assert_select "select[name='game[category_id]']"
  end

  test "creating a game saves players and selects a word and one imposter" do
    assert_difference "Game.count", 1 do
      assert_difference "Player.count", 3 do
        post games_path, params: {
          game: {
            category_id: @category.id,
            player_names: [ " Alex ", "Blair", "Casey", "" ]
          }
        }
      end
    end

    game = Game.order(:id).last

    assert_redirected_to game_path(game)
    assert_equal @category, game.category
    assert_not_nil game.secret_word
    assert_equal @category.id, game.secret_word.category_id

    assert_equal [ "Alex", "Blair", "Casey" ],
                 game.players.pluck(:name)

    assert_equal [ 1, 2, 3 ], game.players.pluck(:turn_order)
    assert_equal 1, game.players.where(is_imposter: true).count
    assert_equal "setup", game.status
  end
    test "rejects fewer than two players" do
    assert_setup_rejected(
      category_id: @category.id,
      player_names: [ "Alex", "", "   " ]
    )
  end

  test "rejects more than ten players" do
    assert_setup_rejected(
      category_id: @category.id,
      player_names: (1..11).map { |number| "Player #{number}" }
    )
  end

  test "rejects a missing category" do
    assert_setup_rejected(
      category_id: "",
      player_names: [ "Alex", "Blair" ]
    )
  end

  test "rejects a category that does not exist" do
    assert_setup_rejected(
      category_id: Category.maximum(:id) + 1,
      player_names: [ "Alex", "Blair" ]
    )
  end

  test "rejects a category without words" do
    empty_category = Category.create!(name: "Empty Setup Category")

    assert_setup_rejected(
      category_id: empty_category.id,
      player_names: [ "Alex", "Blair" ]
    )
  end

    test "players reveal their roles one at a time" do
    game = create_reveal_game
    word = game.secret_word.word

    get reveal_game_path(game)
    assert_response :success
    assert_select "strong", text: "Alex"
    refute_includes response.body, word

    post reveal_role_game_path(game)
    assert_select "h1", text: "Alex's Role"
    assert_select "strong", text: word

    post pass_role_game_path(game), params: { position: 1 }
    assert_redirected_to reveal_game_path(game)
    follow_redirect!
    assert_select "strong", text: "Blair"
    refute_includes response.body, word
    refute_includes response.body, "You are the Imposter"

    post reveal_role_game_path(game)
    assert_select "h1", text: "Blair's Role"
    assert_includes response.body, "You are the Imposter"
    refute_includes response.body, word

    post pass_role_game_path(game), params: { position: 2 }
    assert_redirected_to game_path(game)
    follow_redirect!
    assert_select "h1", text: "Clue Round"
    assert_equal "playing", game.reload.status
  end

  test "clue turns advance in order and wrap to the first player" do
    game = create_reveal_game
    game.update!(status: "playing")

    get game_path(game)
    assert_select "p strong", text: "Alex"

    post next_turn_game_path(game), params: { position: 1 }
    assert_redirected_to game_path(game)
    follow_redirect!
    assert_select "p strong", text: "Blair"

    get game_path(game)
    assert_select "p strong", text: "Blair"

    post next_turn_game_path(game), params: { position: 2 }
    assert_redirected_to game_path(game)
    follow_redirect!
    assert_select "p strong", text: "Alex"
  end

  private

  def assert_setup_rejected(attributes)
    assert_no_difference [ "Game.count", "Player.count" ] do
      post games_path, params: { game: attributes }
    end

    assert_response :unprocessable_entity
    assert_select ".alert-danger", count: 1
    assert_select "form"
  end

  def create_reveal_game
    game = Game.create!(category: @category, secret_word: @category.words.first)
    game.players.create!(name: "Alex", turn_order: 1, is_imposter: false)
    game.players.create!(name: "Blair", turn_order: 2, is_imposter: true)
    game
  end
end
