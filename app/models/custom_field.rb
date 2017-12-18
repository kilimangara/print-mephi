class CustomField < ApplicationRecord

  FIELD_TYPES = %w[file text]

  FILE_TYPE = 'file'.freeze

  TEXT_TYPE = 'text'.freeze

  ORDER_D = 1

  validates :destiny, inclusion: { in: [1] }

  validates :field_type, inclusion: { in: FIELD_TYPES }

  rails_admin do
    configure :field_type, :enum do
      enum do
        FIELD_TYPES
      end

      default_value 'text'
    end

    configure :destiny, :enum do
      enum do
        {order: 1}
      end

      default_value 1
    end
  end

end
