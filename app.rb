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
  ip = hash[:new_session][:ip]
  country = hash[:new_session][:country]
  landing_page = hash[:new_session][:landing_page]
  session_duration = hash.fetch(:new_session).fetch(:session_duration)
  duration = session_duration/1000
  message = "New session is recorded by Inspectlet:\n#{ip} (#{country})\n#{landing_page}\nSession duration: #{duration} sec.\n[View session on Inspectlet](#{url})"
  api.sendMessage(chat_id, message, {"parse_mode" => "Markdown", "disable_web_page_preview" => true})
end
