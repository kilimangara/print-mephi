module ReplyService

  def respond_tg(type, params={})
    response = self.respond_with type, params
    self.session[:last_message_id] = response['result']['message_id']
  end
end