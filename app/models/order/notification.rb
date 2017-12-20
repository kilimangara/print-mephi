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
      text = "Новый заказ №#{id}\n#{order_lines_as_text}\n#{order_values_as_text}"
      Merchant.all.each do |m|
        bot.send_message(chat_id: m.chat_id, text: text) if m.chat_id
      end
    end
  end
end