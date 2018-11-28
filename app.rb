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

post '/webhook_gitea' do
  token = ENV["TELEGRAM_TOKEN"]
  chat_id = ENV["TELEGRAM_CHAT_ID"]
  api = TelegramAPI.new token
  commit = JSON.parse(request.body.read)["commits"]
  unless commit.nil?
    hash = commit.first
    commit_title = hash.fetch("message")
    commit_author = hash.fetch("author").fetch("name")
    commit_url = hash.fetch("url")
    message = "***Commit by*** `#{commit_author}`:\n``` #{commit_title}```[View on Gitea](#{commit_url})"
  end

  request.body.rewind
  payload = JSON.parse(request.body.read)["pull_request"]
  unless payload.nil?
    pull_request_title = payload.fetch("title")
    if payload.fetch("state") == "open"
      pull_request_author = payload.fetch("user").fetch("username")
      state = payload.fetch("state")
      pull_request_url = payload.fetch("html_url")
    else
      pull_request_author = payload.fetch("merged_by").fetch("username")
      state = payload.fetch("state")
      pull_request_url = payload.fetch("html_url")
    end
    message = "***Pull request*** `#{state}` by `#{pull_request_author}`:\n``` #{pull_request_title}``` \n[View on Gitea](#{pull_request_url})"
  end

  api.sendMessage(chat_id, message, {"parse_mode" => "Markdown"})
end
