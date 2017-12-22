class Client < ApplicationRecord

  has_many :orders

  after_update :bonus_points_changed, if: :bonus_points_changed?

  def format_as_text
    "Клиент: #{name} #{phone}.\nБонусные баллы:#{bonus_points}"
  end

  def bonus_points_changed
    bot = Telegram.bots[:user]
    bot.send_message(chat_id: chat_id, text: "Кол-во бонусных баллов изменено.\nУ вас #{bonus_points} баллов")
  end
end
