class Order < ApplicationRecord
  belongs_to :client

  has_many :order_lines

  belongs_to :delivery_variant

  accepts_nested_attributes_for :order_lines


  include Notification
  include CustomFields

  after_update :price_changed, if: :price_changed?


  def price_changed
    bot = Telegram.bots[:user]
    chat_id = client.chat_id
    bot.send_message(chat_id: chat_id, text: "Ваш заказ №#{id} оценен в #{total} рублей.")
  end

  def price_changed?
    total_changed?
  end

  def order_lines_as_text
    text = "В заказе:\n"
    order_lines.each_with_index do |ol, index|
      text << "    #{index + 1 }. #{ol.name} x #{ol.quantity}"
    end
    text
  end
end
