class AdminBotController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  context_to_action!

  def register(*args)
    value = !args.empty? ? args.join(' ') : nil
    merchant = Merchant.where(phone: value).first
    respond_with :message, text: 'Продавец с таким телефоном не найден'
    merchant.chat_id = chat['id']
    merchant.save
  end

  def orders(*)
    orders = Order.where('created_at >= ?', 3.days.ago).where(canceled: false, fulfilled: false, total: 0)
  end

  def non_priced_orders(*)
    orders = Order.where('created_at >= ?', 3.days.ago).where(canceled: false, fulfilled: false).where.not(total:0)
  end
end