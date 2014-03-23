class User < ActiveRecord::Base
  attr_accessible :name, :email, :barcode
  has_many :transactions
end
