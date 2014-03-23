class User < ActiveRecord::Base
  has_many :transactions
  validates :barcode, uniqueness: true
  validates_presence_of :name, :email
end
