
module CategoryService
  BACK_WORD = '← Назад'.freeze
  OPEN_CURRENT_CATEGORY = 'Что в этой категории?'.freeze
  IN_CART_WORD = 'В корзину'.freeze

  attr_reader :parent_category, :parent_category_name

  def define_category
    @parent_category = Category.where(id: self.session[:category_parent_id]).first
    @parent_category_name = parent_category ? parent_category.name : 'Каталог'
  end

  def build_category_keyboard(categories, parent_category_id=nil)
    kb = []
    categories.each do |c|
      kb.append([c.name])
    end
    kb.append([BACK_WORD]) if parent_category_id
    if parent_category_id
      c = Category.find(parent_category_id)
      kb.append([OPEN_CURRENT_CATEGORY]) unless c.products.empty?
    end
    kb.append([IN_CART_WORD]) unless self.session[:cart].empty?
    {
        keyboard: kb,
        resize_keyboard: true,
        one_time_keyboard: true,
        selective: true
    }
  end

  def category_intro_message
    categories = Category.where(parent_category: parent_category, hidden: false).order(:position)
    reply_markup = build_category_keyboard(categories)
    self.respond_with :message, text: "Вы в категории #{parent_category_name || 'Каталог'}", reply_markup: reply_markup
  end

  def category_missing
    self.respond_with :message, text:'Такой категории нет'
  end

  def edit_reply_markup(params)
    msg_id = self.session[:last_message_id]
    chat_id = chat['id']
    self.bot.edit_message_reply_markup({chat_id:chat_id, message_id: msg_id}.merge(params))
  end

end