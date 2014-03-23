class User < ActiveRecord::Base
  attr_accessible :name, :email, :barcode
  has_many :transactions
  validates :barcode, uniqueness: true
  validates_presence_of :name, :email
end
