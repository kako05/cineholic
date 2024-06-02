class CommentsController < ApplicationController
  before_action :find_film, only: [:index, :create]
  def index
    @comments = @film.comments
  end

  def new
    @comment = Comment.new
  end

  def create
    @comment = Comment.create(comment_params)
    @comment.user = current_user
    if @comment.save
      redirect_to film_path(@film)
    else
      render :new
    end
  end

  private
  def find_film
    @film = Film.find(params[:film_id])
  end
  def comment_params
    params.require(:comment).permit(:text).merge(user_id: current_user.id, film_id: params[:film_id])
  end
end
