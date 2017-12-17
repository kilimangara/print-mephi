class Category < ApplicationRecord

  has_many :products
  belongs_to :parent_category, class_name: 'Category', required: false

  has_many :inner_categories, class_name: 'Category', foreign_key: 'parent_category_id'
end
