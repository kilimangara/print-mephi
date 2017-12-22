module OrderService
  require 'json'

  CREATE_ORDER = 'Оформить заказ'.freeze
  BACK = 'Обратно в категории'.freeze
  REGISTER = 'Зарегистрироваться'.freeze

  CALLBACK_DELETE_POSITION = 0

  def build_order
    order_attributes = formalize_order_lines
    field_attributes = formalize_order_values
    Order.create(total: session[:total], order_lines_attributes: order_attributes,
                 order_values_attributes: field_attributes, client: @client,
                 delivery_variant_id: session[:delivery])
  end

  def after_order
    session[:cart] = []
    session[:category_parent_id] = nil
    session[:order_fields] = []
    session[:variant_id] = nil
    session[:messages_to_delete] = []
    session[:total] = 0
  end

  def formalize_order_lines
    order_lines_attributes = []
    ids = !session[:cart].empty? ? session[:cart].map { |i| i[:variant] } : []
    variants = ids.empty? ? [] : Variant.find(ids)
    variants.each_with_index do |item, index|
      q = session[:cart].at(index)[:quantity]
      order_lines_attributes.append(name: item.name,
                                    price: item.price,
                                    quantity: q)
    end
    order_lines_attributes
  end

  def formalize_order_values
    attrs = []
    session[:order_fields].each do |field|
      attrs.append(field_type: field[:field_type], value: field[:value])
    end
    attrs
  end

  def show_cart
    return respond_with :message, text: 'Корзина пуста', reply_markup: build_cart_keyboard if session[:cart].empty?
    ids = !session[:cart].empty? ? session[:cart].map { |i| i[:variant] } : []
    total_price = 0
    respond_with :message, text: "Часы работы сегодня: #{Option.first.working_time}"
    variants = ids.empty? ? [] : Variant.find(ids)
    variants.each_with_index do |variant, index|
      quantity = session[:cart].at(index)[:quantity]
      total_price += variant.price * quantity
      text = "#{index + 1}.#{variant.product.name} #{variant.name} x #{quantity}"
      response = respond_with :message, text: text, reply_markup: {
        inline_keyboard: [
          [{ text: 'Удалить', callback_data: JSON.generate(type: CALLBACK_DELETE_POSITION, index: index) }]
        ]
      }
      session[:messages_to_delete].push(response['result']['message_id'])
    end
    session[:total] = total_price
    response = respond_with :message, text: "Сумма заказа #{total_price} рублей.\nЗаказ будет переоценен продавцом!",
                                      reply_markup: build_cart_keyboard
    session[:messages_to_delete].push(response['result']['message_id'])
  end

  def delete_messages
    session[:messages_to_delete].each do |message_id|
      bot.delete_message(chat_id: chat['id'], message_id: message_id)
    end
    session[:messages_to_delete] = []
  end

  def no_such_delivery
    respond_with :message, text: 'Такого варианта нет', reply_markup: build_delivery_keyboard
  end

  def choose_delivery
    respond_with :message, text: 'Выберите вариант самовывоза', reply_markup: build_delivery_keyboard
  end

  def build_cart_keyboard
    kb = []
    kb.append([{ text: REGISTER, request_contact: true }]) unless self.logged_in?
    if self.logged_in?
      kb.append([CREATE_ORDER]) unless session[:cart].empty?
    end
    kb.append([BACK])
    {
      keyboard: kb,
      resize_keyboard: true,
      one_time_keyboard: true,
      selective: true
    }
  end

  def build_delivery_keyboard
    kb = []
    DeliveryVariant.where(active: true).each do |d|
      kb.append([d.name])
    end
    {
        keyboard: kb,
        resize_keyboard: true,
        one_time_keyboard: true,
        selective: true
    }
  end
end
