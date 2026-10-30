class CategoriesController < ApplicationController
  before_action :set_category, only: [:show, :edit, :update, :destroy]

  def index
    @categories = Category.order(:name)

    if params[:search].present?
      @categories = @categories.where(
        "LOWER(name) LIKE ?",
        "%#{Category.sanitize_sql_like(params[:search].downcase)}%"
      )
    end
  end

  def show
    @words = @category.words.order(:word)
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_to @category, notice: "Category created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      redirect_to @category, notice: "Category updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @category.destroy
      redirect_to categories_path, notice: "Category deleted successfully."
    else
      redirect_to @category, alert: @category.errors.full_messages.to_sentence
    end
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :description)
  end
end
