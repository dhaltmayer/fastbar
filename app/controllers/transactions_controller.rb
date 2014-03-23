class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:index, :show, :edit, :update, :destroy]

  def pos_create
    @user = User.find_by_barcode(params[:barcode])
    if @user.blank?
      raise ActionController::RoutingError.new('You need a barcode!')
    end
    @user.transactions.new
  end

  def new
    @transaction = Transaction.new
  end

  def create
    @transaction = Transaction.new(params[:transaction])
    if @transaction.save
      redirect_to root_url, notice: "Thank you for signing up!"
    else
      render "new"
    end
  end

  def index
    @transaction = Transaction.all?
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
