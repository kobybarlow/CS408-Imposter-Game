require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "category with a name is valid" do
    category = Category.new(name: "Food")

    assert category.valid?
  end

  test "category requires a name" do
    category = Category.new(name: "")

    assert_not category.valid?
    assert_includes category.errors[:name], "can't be blank"
  end

  test "category names must be unique" do
    Category.create!(name: "Food")
    duplicate = Category.new(name: "Food")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "category can contain multiple words" do
    category = Category.create!(name: "Food")
    category.words.create!(word: "Pizza")
    category.words.create!(word: "Tacos")

    assert_equal 2, category.words.count
  end
end
