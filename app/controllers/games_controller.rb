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

    if @game.status == "playing"
      @current_player = @game.players.find_by!(turn_order: @game.clue_position)
      render :play
    end
  end
  def reveal
    @game = Game.find(params[:id])
    return redirect_to game_path(@game) unless @game.status == "setup"

    @player = @game.players.find_by!(turn_order: @game.reveal_position)
  end

  def reveal_role
    @game = Game.find(params[:id])
    return redirect_to game_path(@game), status: :see_other unless @game.status == "setup"

    @player = @game.players.find_by!(turn_order: @game.reveal_position)
    @role_visible = true

    response.headers["Cache-Control"] = "no-store"
    render :reveal
  end

  def pass_role
    game = Game.find(params[:id])

    game.with_lock do
      if game.status == "setup" && params[:position] == game.reveal_position.to_s
        next_position = game.reveal_position + 1

        if game.players.exists?(turn_order: next_position)
          game.update!(reveal_position: next_position)
        else
          game.update!(status: "playing")
        end
      end
    end

    destination = game.status == "setup" ? reveal_game_path(game) : game_path(game)
    redirect_to destination, status: :see_other
  end

  def next_turn
    game = Game.find(params[:id])

    game.with_lock do
      if game.status == "playing" && params[:position] == game.clue_position.to_s
        next_position = game.clue_position + 1
        next_position = 1 unless game.players.exists?(turn_order: next_position)

        game.update!(clue_position: next_position)
      end
    end

    redirect_to game_path(game), status: :see_other
  end
end
