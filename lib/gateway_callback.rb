# todo: rename in SmsGatewayCallback ?

class GatewayCallback
  # PROJECT_TITLE = "btc_sms_wallets"
  PROJECT_TITLE = "BTC SMS Wallet"

  def initialize(params)
    # https://github.com/bobes/textmagic/blob/master/lib/textmagic/api.rb#L112
    # ???
    # @message = api.message_status(p[:message_id])
    # @attributes = { sms_id: p[:message_id], sent_at: p[:timestamp],
    #   delivery_status: p[:status], cost_credit: p[:credit_cost]  }


    # {"message_id"=>"139173", "text"=>"Callback URL test for user makevoid", "timestamp"=>"1408395151", "from"=>"9991234567"}
    p = params
    @from = p["from"]
    @message = p["text"].strip
    # timestamp
    # message_id
  end

  def handle
    @user = User.first(number: @from)
    return view("USER NOT FOUND - Reply with a message containing only the word: REGISTER to register to #{PROJECT_TITLE}") unless @user

    # puts "Handing callback:"
    # TODO: send debugging reply "BALANCE max" => "the number was incorrect"
    reply = case @message
    when /^BALANCE/i then balance
    when /^SEND/i    then deliver
    when /^HISTORY/i then history
    else
      "ERROR [TODO: add exception notification]"
    end

    sms_send reply
    reply
  end


  REGEX = {
    balance:      /^BALANCE/i,
    balance_user: /^BALANCE\s+(\d+)/i, # support also btc addresses
    # deliver:      /^SEND\s+(\d+)\s+(\w+)\s+TO\s+(\d+)/i,
    deliver:      /^SEND\s+(?<amount>\d+\.\d+)\s+(?<currency>\w+)\s+TO\s+(?<recipient>\d+)/i,
    history:      /^HISTORY/i,
    # TODO: pin protection
  }

  private

  def sms_send(reply)
    Sms.deliver @user.number, reply
  end

  # actions

  def balance
    case @message
    when REGEX[:balance]
      balance = 0.0001
      balance = @user.balance
      "Your balance: #{balance} BTC"
    when REGEX[:balance_user]
      "User balance is: 0 BTC [TODO]"
    else
      view "BALANCE REQUEST MALFORMED"
    end
  end

  def deliver
    match = @message.match REGEX[:deliver]
    return view("SEND REQUEST MALFORMED") unless match

    amount = match[:amount]
    currency = match[:currency].downcase.to_sym
    curr = Currency::CURRENCIES[currency]
    return view("We can't guess the amount you want to transfer, please specify if you want to transfer #{amount} BTC or #{amount} mBTC in your SEND message.") unless curr
    
    balance = @user.balance
    amount_satoshi = curr.curr_to_satoshi amount
    return view("There's not enough money in your account to send #{amount} #{currency}") if balance < amount_satoshi

    recipient = match[:recipient]
    "You sent #{amount} #{currency} TO #{recipient}"
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
