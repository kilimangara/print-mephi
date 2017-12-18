module OrderService
  require 'json'

  CREATE_ORDER = 'Оформить заказ'.freeze
  BACK = 'Обратно в категории'.freeze

  CALLBACK_DELETE_POSITION = 0

  def show_cart
    ids = !session[:cart].empty? ? session[:cart].map { |i| i[:variant] } : []
    total_price = 0
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
    response = respond_with :message, text: "Сумма заказа #{total_price}. Заказ будет переоценен продавцом!",
                                      reply_markup: build_cart_keyboard
    session[:messages_to_delete].push(response['result']['message_id'])
  end

  def delete_messages
    session[:messages_to_delete].each do |message_id|
      bot.delete_message(chat_id: chat['id'], message_id: message_id)
    end
    session[:messages_to_delete] = []
  end

  def build_cart_keyboard
    kb = []
    kb.append([CREATE_ORDER]) unless session[:cart].empty?
    kb.append([BACK])
    {
      keyboard: kb,
      resize_keyboard: true,
      one_time_keyboard: true,
      selective: true
    }
  end
end
