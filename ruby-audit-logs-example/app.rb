# frozen_string_literal: true

require 'dotenv/load'
require 'sinatra'
require 'workos'
require 'json'
require_relative 'audit_log_events.rb'

# Pull API key from ENV variable
WorkOS.key = ENV['WORKOS_API_KEY']

# Input your connection ID from your WorkOS dashboard
# Configure your Redirect URIs on the dashboard
# configuration page.
CONNECTION_ID = ENV['WORKOS_CONNECTION_ID']
CLIENT_ID = ENV['WORKOS_CLIENT_ID']
REDIRECT_URI = 'http://localhost:4567/callback'


use(
  Rack::Session::Cookie,
  key: 'rack.session',
  domain: 'localhost',
  path: '/',
  expire_after: 2_592_000,
  secret: SecureRandom.hex(16)
)

get '/' do
  erb :login, :layout => :layout
end


post '/set_org' do
  @organization_id = params[:org]

  session[:organization_id] = @organization_id
  
  organization = WorkOS::Organizations.get_organization(
  id: @organization_id
  )
  
  @org_name = organization.name
  session[:organization_name] = @org_name
  erb :send_events, :layout => :layout
end

post '/send_event' do
  event_type = params[:event]
  organization_id = session[:organization_id]

  events = [
        $user_signed_in,
        $user_logged_out,
        $user_organization_deleted,
        $user_connection_deleted,
    ]

  event = events[event_type.to_i]

  WorkOS::AuditLogs.create_event(
    organization: organization_id,
    event: event
  )

  erb :send_events, :layout => :layout
end

get '/export_events' do
  erb :export_events, :layout => :layout
end  


# Logout a user
get '/logout' do
  session[:user] = nil

  redirect '/'
end
