class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
  end

  def edit
  end

  def update
    if current_user.update(user_params)
    redirect_to "#"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:nickname, :email)
  end
end