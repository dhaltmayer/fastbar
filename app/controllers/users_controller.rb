class UsersController < ApplicationController
  #before_action :set_user, only: [:index, :show, :edit, :update, :destroy]

  def new
    @user = User.new
  end

  def create

    @user = User.new(user_params)
    @user.transactions.build(params[:user][:transaction])
    if @user.save
      redirect_to root_url, notice: "Thank you for signing up!"
    else
      render "new"
    end
  end

  def index
    @users = User.all
  end

  def edit
  end

  def show
    @user = User.find(params[:id])
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'user was successfully updated.' }
        format.json { head :no_content }
      end
    end
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to transactions_url }
      format.json { head :no_content }
    end
  end



private

  def user_params
    params.require(:user).permit(:name, :email, :barcode)
  end
end
