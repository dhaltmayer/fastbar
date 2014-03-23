class TransactionSerializer < ActiveModel::Serializer
  attributes :id, :price, :product, :user_id
end
