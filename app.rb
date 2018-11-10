require 'sinatra'
require 'pry'
require 'telegramAPI'

post '/webhook_sentry' do
  token = ENV["TELEGRAM_TOKEN"]
  chat_id = ENV["TELEGRAM_CHAT_ID"]
  api = TelegramAPI.new token
  error = JSON.parse(request.body.read)["message"]
  request.body.rewind
  url = JSON.parse(request.body.read)["url"]
  message = "New exception detected by Sentry:\n*NoMethodError — #{error}*\n[View exception details on Sentry](#{url})"
  api.sendMessage(chat_id, message, {"parse_mode" => "Markdown"})
end

post '/webhook_inspectlet' do
  token = ENV["TELEGRAM_TOKEN"]
  chat_id = ENV["TELEGRAM_CHAT_ID"]
  api = TelegramAPI.new token
  hash = eval(request.params["payload"])
  url = hash[:new_session][:sessionlink]
  message = "New session is recorded by Inspectlet\n[View session on Inspectlet](#{url})"
  api.sendMessage(chat_id, message, {"parse_mode" => "Markdown"})
end
