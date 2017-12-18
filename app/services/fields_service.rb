module FieldsService

  attr_reader :to_fulfill

  def pre_build_order_fields
    CustomField.where(destiny: CustomField::ORDER_D, active: true).each do |c_f|
      custom_field = { field_type: c_f.field_type, value: nil, fulfilled: false }
      self.session[:order_fields].push(custom_field)
    end
  end

  def last_not_fulfilled
    @to_fulfill = self.session[:order_fields].reject { |item| item[:fulfilled] }.first
  end

  def resolve_by_type!(field_type, message)
    case field_type
    when CustomField::FILE_TYPE
      photo_obj = message.fetch('photo', []).first
      return nil unless photo_obj
      index = self.session[:order_fields].index { |item| item[:field_type] == field_type && !item[:fulfilled]}
      return nil unless index
      self.session[:order_fields].at(index).merge!(value: photo_obj.fetch('file_id'), fulfilled: true)
    when CustomField::TEXT_TYPE
      text = message.fetch('text', nil)
      return nil unless text
      index = self.session[:order_fields].index { |item| item[:field_type] == field_type && !item[:fulfilled]}
      return nil unless index
      self.session[:order_fields].at(index).merge!(value:text, fulfilled: true)
    end
  end
end