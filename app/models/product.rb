class Product < ApplicationRecord

  after_create :create_variant

  belongs_to :category
  has_many :variants

  private

  def create_variant
    Variant.create(product_id: id, name: name, price: price, hidden: false)
  end
end
