class Merchant < ApplicationRecord
  after_create :create_link
  validates :phone, uniqueness: true

  private

  def create_link
    self.link_to_tg = "t.me/print_mephi_a_bot?register=#{phone}"
    save
  end
end
