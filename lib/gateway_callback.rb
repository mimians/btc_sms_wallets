# todo: rename in SmsGatewayCallback ?

class GatewayCallback
  def initialize(params)
    # https://github.com/bobes/textmagic/blob/master/lib/textmagic/api.rb#L112
    @message = api.message_status(p[:message_id])
    @text = message.text.strip
    @from = message.from

    p = params
    @attributes = { sms_id: p[:message_id], sent_at: p[:timestamp],
      delivery_status: p[:status], cost_credit: p[:credit_cost]  }
  end

  def handle
    @user = User.find(number: @from)
    return view("USER NOT FOUND - REGISTER YOURSELF") unless @user

    # TODO: send debugging reply "BALANCE max" => "the number was incorrect"
    case @message
    when /^BALANCE/i then balance
    when /^SEND/i    then send
    when /^HISTORY/i then history
    end
  end

  REGEX = {
    balance:      /^BALANCE/i,
    balance_self: /^BALANCE\s+(\d+)/i, # support also btc addresses
    deliver:      /^SEND\s+(\w+)\s+TO\s+(\d+)/i,
    history:      /^HISTORY/i,
    # TODO: pin protection
  }

  private

  # actions

  def balance
    case @message
    when REGEX[:balance]

    when REGEX[:balance_self]

    else
      view "BALANCE REQUEST MALFORMED"
    end
  end

  def deliver
    match = @message.match REGEX[:deliver]
    return view("SEND REQUEST MALFORMED") unless match

    wallet = Wallet.get @user
    return view("")
    balance = wallet.balance
    ""
  end

  def history
    match = @message.match REGEX[:history]
    return view("HISTORY REQUEST MALFORMED") unless match

  end

  private

  def view(message)
    "#{message} [debug...]"
  end

end

class SMSApi

end