# frozen_string_literal: true

require 'dotenv/load'
require 'sinatra'
require 'workos'
require 'date'
require_relative 'audit_log_events.rb'

# Pull API key and Client ID from ENV variable
WorkOS.key = ENV['WORKOS_API_KEY']
CLIENT_ID = ENV['WORKOS_CLIENT_ID']

enable :sessions

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

get '/set_org' do
  @organization_id = session[:organization_id]
  @org_name = session[:organization_name]
  erb :send_events, :layout => :layout
end  

post '/send_event' do
  event_type = params[:event]
  @organization_id = session[:organization_id]
  @org_name = session[:organization_name]

  events = [
        $user_signed_in,
        $user_logged_out,
        $user_organization_deleted,
        $user_connection_deleted,
    ]

  event = events[event_type.to_i]

  WorkOS::AuditLogs.create_event(
    organization: @organization_id,
    event: event
  )

  erb :send_events, :layout => :layout
end

get '/export_events' do
  @organization_id = session[:organization_id]
  @org_name = session[:organization_name]
  erb :export_events, :layout => :layout
end

post '/get_events' do
  organization_id = session[:organization_id]
  event_type = params[:event]
  today = DateTime.now.to_s
  last_month = DateTime.now.prev_month.to_s
  
  if event_type == 'generate_csv'
    audit_log_export = WorkOS::AuditLogs.create_export(
      organization: organization_id,
      range_start: last_month,
      range_end: today
    )
    session[:export_id] = audit_log_export.id
    puts audit_log_export.id
    redirect '/export_events'
  end
  
  if event_type == 'access_csv'
    export_id = session[:export_id].to_s
    puts export_id
    audit_log_export = WorkOS::AuditLogs.get_export(
      id: export_id
    )
    url = audit_log_export.url

    redirect url
  end

end  


# Logout a user
get '/logout' do
  session[:organization_id] = nil
  session[:organization_name] = nil
  session[:export_id] = nil
  redirect '/'
end
