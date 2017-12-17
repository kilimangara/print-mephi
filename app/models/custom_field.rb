class CustomField < ApplicationRecord

  FIELD_TYPES = %w[file text]

  validates :destiny, inclusion: { in: [1] }

  validates :field_type, inclusion: { in: FIELD_TYPES }

end
