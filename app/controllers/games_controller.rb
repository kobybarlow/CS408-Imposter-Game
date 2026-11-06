class GamesController < ApplicationController
  def new
    @categories = Category.order(:name)
  end

  def create
    @categories = Category.order(:name)

    game_params = params.require(:game).permit(
      :category_id,
      player_names: []
    )

    @category = Category.find_by(id: game_params[:category_id])

    @player_names = Array(game_params[:player_names])
      .map(&:strip)
      .reject(&:blank?)

    if @category.nil?
      @error = "Choose a valid category."
    elsif @category.words.empty?
      @error = "Choose a category that contains words."
    elsif !@player_names.length.between?(2, 10)
      @error = "Enter between 2 and 10 players."
    end

    if @error
      render :new, status: :unprocessable_entity
    else
      @game = Game.transaction do
        game = Game.create!(
          category: @category,
          secret_word: @category.words.to_a.sample,
          status: "setup"
        )

        imposter_index = rand(@player_names.length)

        @player_names.each_with_index do |name, index|
          game.players.create!(
            name: name,
            turn_order: index + 1,
            is_imposter: index == imposter_index
          )
        end

        game
      end

      redirect_to game_path(@game)
    end
  end

  def show
    @game = Game.find(params[:id])
  end
end
