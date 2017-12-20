module AdminOrderService
  CALLBACK_TYPE_SET_COST = 0
  CALLBACK_TYPE_CANCEL_ORDER = 1
  CALLBACK_TYPE_ORDER_FULFILLED = 2

  def format_all_text(order)
    "Заказ №#{order.id}\n#{order.order_lines_as_text}\n#{order.order_values_as_text}\nСтоимость: #{order.total}"
  end

  def respond_with_order(order)
    text = "Заказ №#{order.id}\n#{order.order_lines_as_text}\n#{order.order_values_as_text}\n
            Стоимость: #{order.total}"
    markup = {
      inline_keyboard: [
        [text: 'Оценить заказ', callback_data: JSON.generate(order_id: order.id, type: CALLBACK_TYPE_SET_COST)],
        [text: 'Отменить заказ', callback_data: JSON.generate(order_id: order.id, type: CALLBACK_TYPE_CANCEL_ORDER)]
      ]
    }
    respond_with :message, text: text, reply_markup: markup
  end

  def respond_with_order_priced(order)
    text = "Заказ №#{order.id}\n#{order.order_lines_as_text}\n#{order.order_values_as_text}\nСтоимость: #{order.total}"
    markup = {
      inline_keyboard: [
        [text: 'Переоценить заказ', callback_data: JSON.generate(order_id: order.id, type: CALLBACK_TYPE_SET_COST)],
        [text: 'Отменить заказ', callback_data: JSON.generate(order_id: order.id, type: CALLBACK_TYPE_CANCEL_ORDER)],
        [text: 'Заказ выполнен', callback_data: JSON.generate(order_id: order.id, type: CALLBACK_TYPE_ORDER_FULFILLED)]
      ]
    }
    respond_with :message, text: text, reply_markup: markup
  end
end
