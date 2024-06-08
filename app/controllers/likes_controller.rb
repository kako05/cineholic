class LikesController < ApplicationController
  before_action :set_film, only: [:create, :destroy]

  def create
    current_user.likes.create(film: @film)
    render partial: 'likes/like', locals: { film: @film }
  end

  def destroy
    current_user.likes.find_by(film: @film)&.destroy
    if params[:referer] == 'my_page'
      render turbo_stream: turbo_stream.remove(helpers.dom_id(@film, :like))
    else
      redirect_to request.referer || root_path
    end
  end

  private

  def set_film
    @film = Film.find(params[:film_id])
  end
end