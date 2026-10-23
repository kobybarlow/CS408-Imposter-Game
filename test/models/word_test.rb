require "test_helper"

class WordTest < ActiveSupport::TestCase
  setup do
    @category = Category.create!(name: "Food")
  end

  test "word with text and a category is valid" do
    word = @category.words.build(word: "Pizza")

    assert word.valid?
  end

  test "word requires text" do
    word = @category.words.build(word: "")

    assert_not word.valid?
    assert_includes word.errors[:word], "can't be blank"
  end

  test "word requires a category" do
    word = Word.new(word: "Pizza")

    assert_not word.valid?
    assert_includes word.errors[:category], "must exist"
  end

  test "word cannot repeat within the same category" do
    @category.words.create!(word: "Pizza")
    duplicate = @category.words.build(word: "Pizza")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:word], "has already been taken"
  end

  test "same word can appear in different categories" do
    @category.words.create!(word: "Pizza")
    other_category = Category.create!(name: "Party Food")
    word = other_category.words.build(word: "Pizza")

    assert word.valid?
  end
end
