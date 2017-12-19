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
      text = "Новый заказ №#{id}\n#{order_lines_as_text}\n"
      order_values.each do |ov|
        case ov.field_type
          when CustomField::TEXT_TYPE
            text << "Комментарий #{ov.value}\n"
          when CustomField::FILE_TYPE
            user_bot = Telegram.bots[:user]
            res = user_bot.get_file(file_id: ov.value)
            file_path = res['result']['file_path']
            text << "Ссылка на файл:\n#{FileService.format_link(user_bot.token, file_path)}"
        end
      end
      Merchant.all.each do |m|
        bot.send_message(chat_id: m.chat_id, text: text) if m.chat_id
      end
    end
  end
end