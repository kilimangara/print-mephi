class Order
  module CustomFields

    included do
      accepts_nested_attributes_for :order_values

    end
  end
end