class Order < ApplicationRecord
  belongs_to :client

  has_many :order_lines

  belongs_to :delivery_variant

  accepts_nested_attributes_for :order_lines


  include Notification
  include CustomFields

  ORDER_LIMIT = 3

  after_update :price_changed, if: :price_changed?
  after_update :order_canceled, if: :canceled_changed?
  after_update :order_fulfilled, if: :fulfilled_changed?

  after_create :notify_spam, if: :spam?


  def price_changed
    bot = Telegram.bots[:user]
    chat_id = client.chat_id
    bot.send_message(chat_id: chat_id, text: "Ваш заказ №#{id} находится в исполнении.\nСумма заказа #{total} рублей.")
  end

  def order_canceled
    bot = Telegram.bots[:user]
    chat_id = client.chat_id
    bot.send_message(chat_id: chat_id, text: "Ваш заказ №#{id} отменен")
  end

  def order_fulfilled
    bot = Telegram.bots[:user]
    chat_id = client.chat_id
    bot.send_message(chat_id: chat_id, text: "Ваш заказ №#{id} готов.\nСумма заказа #{total} рублей.")
  end

  def price_changed?
    total_changed?
  end

  def delivery_variant_as_text
    "Вариант доставки: #{delivery_variant.name}"
  end

  def order_lines_as_text
    text = "В заказе:\n"
    order_lines.each_with_index do |ol, index|
      text << "    #{index + 1 }. #{ol.name} x #{ol.quantity}"
    end
    text
  end

  def spam?
    Order.where('created_at >= ? AND client_id = ?', 5.minutes.ago, client.id).count >= ORDER_LIMIT
  end

  def order_values_as_text
    text = ''
    order_values.each do |ov|
      case ov.field_type
        when CustomField::TEXT_TYPE
          text << "Комментарий: #{ov.value}\n"
        when CustomField::FILE_TYPE
          user_bot = Telegram.bots[:user]
          res = user_bot.get_file(file_id: ov.value)
          file_path = res['result']['file_path']
          text << "Ссылка на файл:\n#{FileService.format_link(user_bot.token, file_path)}\n"
      end
    end
    text
  end
end
