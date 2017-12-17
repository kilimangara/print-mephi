class Order < ApplicationRecord

  belongs_to :client

  has_many :order_lines

  belongs_to :delivery_variant

  has_many :order_values

  accepts_nested_attributes_for :order_lines

  included Notification
  included CustomFields
end
