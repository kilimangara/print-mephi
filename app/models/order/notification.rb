class Order
  module Notification
    extend ActiveSupport::Concern

    def self.included(receipent)

    end

    def send_notification

    end
  end
end