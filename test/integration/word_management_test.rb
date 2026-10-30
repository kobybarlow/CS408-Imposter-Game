
require "test_helper"

class WordManagementTest < ActionDispatch::IntegrationTest
  setup do
    @category = Category.create!(
      name: "Test Foods",
      description: "Food category"
    )

    @word = @category.words.create!(word: "Pizza")
  end

  test "displays words in a category" do
    get category_path(@category)

    assert_response :success
    assert_select "li", text: /Pizza/
  end

  test "adds a word to a category" do
    assert_difference("Word.count", 1) do
      post category_words_path(@category), params: {
        word: { word: "Burger" }
      }
    end

    assert_redirected_to category_path(@category)
    assert @category.words.exists?(word: "Burger")
  end

  test "rejects duplicate words" do
    assert_no_difference("Word.count") do
      post category_words_path(@category), params: {
        word: { word: "Pizza" }
      }
    end

    assert_redirected_to category_path(@category)
  end

  test "edits an existing word" do
    patch category_word_path(@category, @word), params: {
      word: { word: "Pepperoni Pizza" }
    }

    assert_redirected_to category_path(@category)
    assert_equal "Pepperoni Pizza", @word.reload.word
  end

  test "deletes a word" do
    assert_difference("Word.count", -1) do
      delete category_word_path(@category, @word)
    end

    assert_redirected_to category_path(@category)
  end

  test "rejects blank words" do
    assert_no_difference("Word.count") do
      post category_words_path(@category), params: {
        word: { word: "" }
      }
    end

    assert_redirected_to category_path(@category)
  end
end
