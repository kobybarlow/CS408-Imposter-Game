
class WordsController < ApplicationController
  before_action :set_category
  before_action :set_word, only: [ :edit, :update, :destroy ]

  def create
    @word = @category.words.build(word_params)

    if @word.save
      redirect_to @category, notice: "Word added successfully."
    else
      redirect_to @category,
                  alert: @word.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @word.update(word_params)
      redirect_to @category, notice: "Word updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @word.destroy
      redirect_to @category, notice: "Word deleted successfully."
    else
      redirect_to @category,
                  alert: @word.errors.full_messages.to_sentence
    end
  end

  private

  def set_category
    @category = Category.find(params[:category_id])
  end

  def set_word
    @word = @category.words.find(params[:id])
  end

  def word_params
    params.require(:word).permit(:word)
  end
end
