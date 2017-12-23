class Order
  module Notification
    extend ActiveSupport::Concern

    def self.included(receipent)
      receipent.class_eval do
        after_create :send_notification
      end
    end

    def send_notification
      bot = Telegram.bots[:admin]
      text = "Новый заказ №#{id}\n#{order_lines_as_text}\n#{delivery_variant_as_text}\n#{order_values_as_text}\n#{client.format_as_text}"
      Merchant.all.each do |m|
        bot.send_message(chat_id: m.chat_id, text: text) if m.chat_id
      end
    end

    def notify_spam
      bot = Telegram.bots[:admin]
      markup = {
          inline_keyboard:[
              [text:'Забанить!', callback_data: JSON.generate(client_id: client.id, type: AdminOrderService::CALLBACK_TYPE_BAN_USER)]
          ]
      }
      text = "#{client.format_as_text}\nДелает подозрительно много заказов ..."
      Merchant.all.each do |m|
        bot.send_message(chat_id: m.chat_id, text: text, reply_markup: markup) if m.chat_id
      end
    end
  end
end