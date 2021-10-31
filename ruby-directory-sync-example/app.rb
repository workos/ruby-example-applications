# frozen_string_literal: true

require 'dotenv/load'
require 'sinatra'
require 'workos'
require 'json'

# Pull API key from ENV variable
WorkOS.key = ENV['WORKOS_API_KEY']

get '/' do
  @directories = WorkOS::DirectorySync.list_directories

  erb :index
end

get '/directories/:id' do
  @groups = WorkOS::DirectorySync.list_groups(directory: params[:id])
  @users = WorkOS::DirectorySync.list_users(directory: params[:id])

  erb :directory
end

get '/users/:id' do
  @user = WorkOS::DirectorySync.get_user(params[:id])
  @user_groups = WorkOS::DirectorySync.list_groups(user: params[:id])

  erb :user
end

get '/groups/:id' do
  @group = WorkOS::DirectorySync.get_group(params[:id])
  @group_users = WorkOS::DirectorySync.list_users(group: params[:id])

  erb :group
end
