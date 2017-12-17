class OrderLine < ApplicationRecord
  belongs_to :order

  validates :order_id, presence: false
end
