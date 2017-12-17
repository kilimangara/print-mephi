class Order
  module Notification

    included do
      after_create :send_notifcation
    end

    def send_notification

    end
  end
end