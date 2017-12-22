class UserBotController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  context_to_action!

  include CategoryService
  include ProductService
  include FieldsService
  include OrderService
  include ReplyService

  before_action :chat_banned

  before_action :shop_active

  before_action :define_category, only: [:category, :product]

  before_action :last_not_fulfilled, only: [:custom_fields]

  before_action :logged_in?, only: %i[custom_fields delivery]

  INTRO_KB = 'Продолжить'.freeze

  def start(*args)
    value = !args.empty? ? args.join(' ') : nil
    if value == INTRO_KB
      category
      return
    end
    session[:cart] = []
    session[:category_parent_id] = nil
    session[:order_fields] = []
    session[:variant_id] = nil
    session[:messages_to_delete] = []
    session[:total] = 0
    o = Option.first
    text = "#{o.intro}\nСегодня работаем так: #{o.working_time}"
    respond_with :message, text: text, reply_markup: intro_keyboard

  end

  def login(*)
    return if logged_in?
    contact = payload['contact']
    if contact
      @user = Client.find_or_create_by(phone: contact['phone_number'], name: contact['first_name'],
                                       chat_id: chat['id'])
      session[:client_id] = @user.id
    end
  end

  def bonus(*)
    option = Option.first
    return respond_with :message, text:'Акция закончилась' unless option.action_active
    save_context :bonus
    login
    return respond_with :message, text: 'Зарегестрируйтесь для участия в акции', reply_markup:{
        keyboard: [
            [{ text: OrderService::REGISTER,  request_contact: true}]
        ],
        resize_keyboard: true,
        one_time_keyboard: true,
        selective: true
    } unless logged_in?
    respond_with :message, text: 'Второй раз не получится' if @client.action_used
    @client.bonus_points = option.bonus_points || 100 unless @client.action_used
    @client.action_used = true
    @client.save
    category
  end

  def message(message)
    start([message['text']])
  end

  def category(*args)
    value = !args.empty? ? args.join(' ') : nil
    save_context :category
    return category_intro_message unless value
    if value == CategoryService::OPEN_CURRENT_CATEGORY
      save_context :product
      return respond_with :message, text: 'Выберите товар', reply_markup: build_products_keyboard(parent_category)
    elsif value == CategoryService::BACK_WORD
      save_context :category
      categories = Category.where(parent_category_id: parent_category.parent_category_id)
      parent_id = parent_category.parent_category_id
      session[:category_parent_id] = parent_id
      text = parent_category ? "Вы в категории #{parent_category_name}" : "Что желаешь?"
      return respond_with :message, text: text,
                          reply_markup: build_category_keyboard(categories, parent_id)
    elsif value == CategoryService::IN_CART_WORD
      return cart
    end
    c = Category.where(name: value, hidden: false).first
    return category_missing unless c
    inner_c = c.inner_categories
    if inner_c.empty?
      save_context :product
      respond_with :message, text: 'Выбирай',
                   reply_markup: build_products_keyboard(c.products.where(hidden: false))
    else
      session[:category_parent_id] = c.id
      respond_with :message, text: "Вы в категории #{c.name}", reply_markup: build_category_keyboard(inner_c)
    end
  end

  def product(*args)
    value = !args.empty? ? args.join(' ') : nil
    save_context :product
    if session[:variant_id]
      q = value.to_i
      add_product(session[:variant_id], q)
      respond_with :message, text: 'Товар добавлен в корзину'
      session[:variant_id] = nil
      session[:category_parent_id] = nil
      category_intro_message
      save_context :category
      return
    end
    save_context :product
    if value == ProductService::BACK_WORD
      return category
    end
    product = Product.where(name: value, hidden: false).first
    return product_missing unless product
    session[:variant_id] = product.variants.first.id
    respond_with :message, text: 'Теперь выберите количество'
  end


  def custom_fields(*)
    save_context :custom_fields
    unless last_not_fulfilled
      choose_delivery
      save_context :delivery
    end
    if resolve_by_type!(to_fulfill[:field_type], payload)
      if !last_not_fulfilled
        choose_delivery
        save_context :delivery
      else
        send_step
      end
    else
      respond_with :message, text: 'Неправильный формат данных'
    end
  end

  def delivery(*args)
    save_context :delivery
    value = !args.empty? ? args.join(' ') : nil
    delivery = DeliveryVariant.where(active: true, name: value).first
    return no_such_delivery unless delivery
    session[:delivery] = delivery.id
    session[:total] += delivery.price
    order = build_order
    if order.errors.empty?
      after_order
      respond_with :message,
                   text: "Ваш заказ № #{order.id} принят в обработку.\n#{order.delivery_variant_as_text}\n#{order.order_values_as_text}\n#{order.order_lines_as_text}"
      return category
    end
    respond_with :message, text: "Возникла ошибка"
  end


  def cart(*args)
    value = !args.empty? ? args.join(' ') : nil
    login
    save_context :cart
    return show_cart unless value
    if value == OrderService::CREATE_ORDER
      pre_build_order_fields
      last_not_fulfilled
      send_step
      save_context :custom_fields
    elsif value == OrderService::BACK
      category
    end

  end

  def callback_query(data)
    return unless data
    json_data = JSON.parse(data)
    case json_data['type']
      when OrderService::CALLBACK_DELETE_POSITION
        session[:cart].delete_at(json_data['index'])
        delete_messages
        cart
        answer_callback_query 'Позиция удалена'
      else answer_callback_query 'Произошла ошибка'
    end
  end

  def help(*args)

  end

  def logged_in?
    @client ||= Client.where(id: session[:client_id]).first
  end

  private

  def chat_banned
    bl = BlackList.where(chat_id: chat['id']).first
    respond_with :message, text: "Вы забанены!\n #{bl.reason}" if bl
    throw :abort if bl
  end

  def shop_active
    o = Option.first
    respond_with :message, text: 'Бот временно выключен :(' unless o.active
    throw :abort unless o.active
  end

  def intro_keyboard
    {
        keyboard: [[INTRO_KB]],
        resize_keyboard: true,
        one_time_keyboard: true,
        selective: true
    }
  end


end