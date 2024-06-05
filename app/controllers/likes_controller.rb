class LikesController < ApplicationController
  before_action :set_film
  def create
    like = current_user.likes.build(film_id: params[:film_id])
    like.save
    render partial: 'likes/like', locals: { film: @film }
  end

  def destroy
    like = Like.find_by(film_id: params[:film_id], user_id: current_user.id)
    like.destroy
    render partial: 'likes/like', locals: { film: @film }
  end

  def set_film
    @film = Film.find(params[:film_id])
  end
end
