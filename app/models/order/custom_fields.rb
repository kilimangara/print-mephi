class Order
  module CustomFields

    def self.included(receipent)
      receipent.class_eval do

        has_many :order_values, class_name: 'OrderValue'
        accepts_nested_attributes_for :order_values
      end
    end
  end
end