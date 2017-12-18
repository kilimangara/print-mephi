class Order < ApplicationRecord
  belongs_to :client

  has_many :order_lines

  belongs_to :delivery_variant

  accepts_nested_attributes_for :order_lines


  include Notification
  include CustomFields

end
