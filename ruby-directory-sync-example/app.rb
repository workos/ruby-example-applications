# frozen_string_literal: true

require 'dotenv/load'
require 'sinatra'
require 'workos'
require 'json'

# Pull API key from ENV variable
WorkOS.key = ENV['WORKOS_API_KEY']

get '/' do
  @directories_list = WorkOS::DirectorySync.list_directories
  @directories = @directories_list.data

  erb :index
end

get '/directories/:id' do
  @groups_list = WorkOS::DirectorySync.list_groups(directory: params[:id])
  @groups = @groups_list.data
  @users_list = WorkOS::DirectorySync.list_users(directory: params[:id])
  @users = @users_list.data

  erb :directory
end

get '/users/:id' do
  @user = WorkOS::DirectorySync.get_user(params[:id])
  @user_groups_list = WorkOS::DirectorySync.list_groups(user: params[:id])
  @user_groups = @user_groups_list.data

  erb :user
end

get '/groups/:id' do
  @group = WorkOS::DirectorySync.get_group(params[:id])
  @group_users_list = WorkOS::DirectorySync.list_users(group: params[:id])
  @group_users = @group_users_list.data

  erb :group
end
