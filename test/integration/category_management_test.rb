
require "test_helper"

class CategoryManagementTest < ActionDispatch::IntegrationTest
  setup do
    @category = Category.create!(
      name: "Test Sports",
      description: "Sports category"
    )
  end

  test "displays categories" do
    get categories_path
    assert_response :success
    assert_select "h5", text: "Test Sports"
  end

  test "searches categories" do
    get categories_path, params: { search: "sports" }

    assert_response :success
    assert_select "h5", text: "Test Sports"
  end

  test "creates a category" do
    assert_difference("Category.count", 1) do
      post categories_path, params: {
        category: {
          name: "Movies Test",
          description: "Movie titles"
        }
      }
    end

    assert_redirected_to category_path(Category.last)
  end

  test "rejects duplicate category names" do
    assert_no_difference("Category.count") do
      post categories_path, params: {
        category: {
          name: "Test Sports"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "updates a category" do
    patch category_path(@category), params: {
      category: {
        name: "Updated Sports"
      }
    }

    assert_redirected_to category_path(@category)
    assert_equal "Updated Sports", @category.reload.name
  end

  test "deletes a category" do
    assert_difference("Category.count", -1) do
      delete category_path(@category)
    end

    assert_redirected_to categories_path
  end
end
