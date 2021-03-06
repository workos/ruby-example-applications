
# frozen_string_literal: true

require 'dotenv/load'
require 'sinatra'
require 'workos'
require 'json'
require 'sinatra-websocket'
require 'pry'

set :server, 'thin'
set :sockets, []

# Pull API key from ENV variable
WorkOS.key = ENV['WORKOS_API_KEY']

get '/' do
  @directories_list = WorkOS::DirectorySync.list_directories
  @directories = @directories_list.data

  erb :index, :layout => false
end

get '/directories/:id' do
  @groups_list = WorkOS::DirectorySync.list_groups(directory: params[:id])
  @groups = @groups_list.data
  @users_list = WorkOS::DirectorySync.list_users(directory: params[:id])
  @users = @users_list.data

  erb :directory, :layout => false
end

get '/users/:id' do
  @user = WorkOS::DirectorySync.get_user(params[:id])
  @user_groups_list = WorkOS::DirectorySync.list_groups(user: params[:id])
  @user_groups = @user_groups_list.data

  erb :user, :layout => false
end

get '/groups/:id' do
  @group = WorkOS::DirectorySync.get_group(params[:id])
  @group_users_list = WorkOS::DirectorySync.list_users(group: params[:id])
  @group_users = @group_users_list.data

  erb :group, :layout => false
end


get '/webhooks' do
  if !request.websocket?
    erb :webhooks
  else
    request.websocket do |ws|
      ws.onopen do
        warn("websocket opened")
        settings.sockets << ws
      end
      ws.onmessage do |msg|
        warn("websocket onmessage")
        EM.next_tick { settings.sockets.each{|s| s.send(msg) } }
      end
      ws.onclose do
        warn("websocket closed")
        settings.sockets.delete(ws)
      end
    end
  end
end

post '/webhooks' do
  payload = JSON.parse(request.body.read).to_json
  sig_header = request.env['HTTP_WORKOS_SIGNATURE']
  verified_webhook = WorkOS::Webhooks.construct_event(
    payload: payload.to_s,
    sig_header: sig_header,
    secret: ENV['WORKOS_WEBHOOK_SECRET']
  )
  if verified_webhook
    EM.next_tick { settings.sockets.each{|s| s.send(payload.to_s ) } }
    redirect "/webhooks"
  else
    render :json => {:status => 400, :error => "Webhook failed"} and return
  end
end

