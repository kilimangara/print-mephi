class AdminBotController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  context_to_action!

  include AdminOrderService

  before_action :check_register, only: %i[non_priced_orders orders set_cost]

  def register(*args)
    value = !args.empty? ? args.join(' ') : nil
    merchant = Merchant.where(phone: value).first
    return respond_with :message, text: 'Продавец с таким телефоном не найден' unless merchant
    merchant.chat_id = chat['id']
    merchant.save
    respond_with :message, text: 'Теперь Вы будете получать уведомления о заказах'
  end

  def non_priced_orders(*)
    session[:order_id] = nil
    orders = Order.where(canceled: false, fulfilled: false, total: 0)
    orders.each do |o|
      respond_with_order o
    end
  end

  def orders(*)
    session[:order_id] = nil
    orders = Order.where(canceled: false, fulfilled: false).where.not(total:0)
    orders.each do |o|
      respond_with_order_priced o
    end
  end

  def order(*args)
    value = !args.empty? ? args.join(' ') : nil
    return respond_with :message, text: 'Такого заказа нет' unless value
    order = Order.where(id: value.to_i).first
    return respond_with :message, text: 'Такого заказа нет' unless order
    respond_with_one_order order
  end

  def set_cost(*args)
    save_context :set_cost
    value = !args.empty? ? args.join(' ') : nil
    return respond_with :message, text: 'Попробуй еще раз' unless value
    cost = value.to_i
    o = Order.where(id: session[:order_id]).first
    o.total = cost
    o.save
    respond_with :message, text: 'Сумма заказа изменена'
  end

  def callback_query(data)
    return unless data
    json_data = JSON.parse(data)
    case json_data['type']
      when AdminOrderService::CALLBACK_TYPE_SET_COST
        save_context :set_cost
        session[:order_id] = json_data['order_id']
        respond_with :message, text: 'Введи новую сумму заказа'
        answer_callback_query 'Введите новую сумму заказа'
      when AdminOrderService::CALLBACK_TYPE_CANCEL_ORDER
        order = Order.where(id: json_data['order_id']).first
        return unless order
        order.canceled = true
        order.save
        message = payload['message']
        bot.delete_message(chat_id: message['chat']['id'], message_id: message['message_id'])
        answer_callback_query 'Заказ отменен'
      when AdminOrderService::CALLBACK_TYPE_ORDER_FULFILLED
        order = Order.where(id: json_data['order_id']).first
        return unless order
        order.fulfilled = true
        order.save
        message = payload['message']
        bot.delete_message(chat_id: message['chat']['id'], message_id: message['message_id'])
        answer_callback_query 'Заказ помечен, как выполненный'
      when AdminOrderService::CALLBACK_TYPE_CLIENT_BONUS
        order = Order.where(id: json_data['order_id']).first
        return unless order
        client = order.client
        client.bonus_points -= order.total
        client.bonus_points = 0 if client.bonus_points < 0
        client.save
        answer_callback_query 'Бонусы списаны'
      else answer_callback_query 'Произошла ошибка'
    end
  end

  def check_register
    merchant = Merchant.where(chat_id: chat['id']).first
    respond_with :message, text: 'У вас нет прав доступа к этим действиям' unless merchant
    throw :abort unless merchant
  end

end