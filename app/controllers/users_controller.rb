class UsersController < ApplicationController
  before_action :authenticate_user!
  def show
    @user = current_user
    @comments = @user.comments.includes(:film)
    @likes = @user.likes.includes(:film)
  end

  def edit
  end

  def update
    if current_user.update(user_params)
      redirect_to user(@user)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:nickname, :email)
  end
end
