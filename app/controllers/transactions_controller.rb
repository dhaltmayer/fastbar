class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:index, :show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token

  def pos_create
    @user = User.find_by_barcode(params[:barcode])
    if @user.blank?
      render :status => 404
    end
    @user.transactions.new
  end

  def new
    @transaction = Transaction.new
  end

  def create
    @transaction = Transaction.new(transaction_params)
    if @transaction.save
      redirect_to transactions_path
    else
      render "new"
    end
  end

  def index
    @transaction = Transaction.all
    respond_to do |format|
      format.html
      format.json { render json: @transactions }
    end
  end

  def edit
  end

  def show
  end

  def update
    respond_to do |format|
      if @transaction.update(transaction_params)
        format.html { redirect_to @transaction, notice: 'transaction was successfully updated.' }
        format.json { head :no_content }
      end
    end
  end

  def destroy
    @transaction.destroy
    respond_to do |format|
      format.html { redirect_to transactions_url }
      format.json { head :no_content }
    end
  end

private

  def set_transaction
    @transaction = Transaction.find(params[:id])
  end

  def transaction_params
    params.require(:transaction).permit(:product, :price)
  end
end
