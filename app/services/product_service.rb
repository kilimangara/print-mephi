module ProductService
  BACK_WORD = '← Назад'.freeze
  IN_CART_WORD = 'В корзину'.freeze

  def build_products_keyboard(products)
    kb = []
    products.each do |p|
      kb.append([p.name])
    end
    kb.append([BACK_WORD])
    kb.append([IN_CART_WORD]) unless self.session[:cart].empty?
    {
      keyboard: kb,
      resize_keyboard: true,
      one_time_keyboard: true,
      selective: true
    }
  end

  def add_product(variant_id, quantity=1)
    index = self.session[:cart].index { |item| item[:variant] == variant_id}
    if index
      self.session[:cart].at(index)[:quantity] += quantity
    else
      self.session[:cart] = self.session[:cart].push(variant: variant_id, quantity: quantity)
    end
  end



  def product_missing
    self.respond_with :message, text:'Такого товара нет'
  end
end