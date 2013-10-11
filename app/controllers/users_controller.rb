class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.all
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to @user, notice: 'Machine was successfully created.'
    else
      render action: 'new'
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to users_path, notice: 'User updated.'
    else
      render action: :edit, alert: 'Unable to update user.'
    end
  end

  def destroy
    redirect_to users_path, notice: 'Can\'t delete yourself.' and return if @user == current_user

    @user.destroy
    redirect_to users_path, notice: 'User deleted.'
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    par = params.require(:user).permit(:name, :email, :password)
    par.delete(:password) if par[:password].blank?
    par
  end

end
