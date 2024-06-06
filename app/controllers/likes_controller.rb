class LikesController < ApplicationController
  before_action :set_film, only: [:create]

  def create
    like = current_user.likes.build(film_id: params[:film_id])
    if like.save
      render json: { status: 'success', film_id: @film.id }
    else
      render json: { status: 'error' }, status: :unprocessable_entity
    end
  end

  def destroy
    like = Like.find_by(film_id: params[:film_id], user_id: current_user.id)
    if like.destroy
      render json: { status: 'success'}
    else
      render json: { status: 'error' }, status: :unprocessable_entity
    end
  end

  private

  def set_film
    @film = Film.find(params[:film_id])
  end
end
