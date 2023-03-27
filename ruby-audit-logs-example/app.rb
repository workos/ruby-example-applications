# frozen_string_literal: true

require 'dotenv/load'
require 'sinatra'
require 'workos'
require 'date'
require_relative 'audit_log_events.rb'
require 'pry'

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
  before = params[:before]
  after = params[:after]
  if !before
    @organizations = WorkOS::Organizations.list_organizations(
      limit: 5
    )
  else
    @organizations = WorkOS::Organizations.list_organizations(
      limit: 5,
      before: before,
      after: after
    )
  end
  @before = @organizations.list_metadata["before"]
  @after = @organizations.list_metadata["after"]
  erb :login, :layout => :layout
end


get '/set_org' do
  @organization = WorkOS::Organizations.get_organization(
    id: params[:id]
  )
  @today_iso = Time.now.utc.iso8601
  @last_month_iso = (Time.now - (30 * 86400)).utc.iso8601
  erb :send_events, :layout => :layout
end  

get '/events' do
  link = WorkOS::Portal.generate_link(
    organization: params[:organization_id],
    intent: params[:intent],
    )
  redirect link
end

post '/send_events' do

  organization_id = params["organization_id"]

  event = {
      "action": "user.organization_deleted",
      "version": params[:event_version].to_i,
      "occurred_at": Time.now.utc.iso8601,
      "actor": {
          "type": params[:actor_type],
          "name": params[:actor_name],
          "id": "user_01GBNJC3MX9ZZJW1FSTF4C5938",
      },
      "targets": [
          {
              "type": params[:target_type],
              "name": params[:target_name],
              "id": "team_01GBNJD4MKHVKJGEWK42JNMBGS",
          },
      ],
      "context": {
          "location": "123.123.123.123",
          "user_agent": "Chrome/104.0.0.0",
      },
  }
  WorkOS::AuditLogs.create_event(
    organization: organization_id,
    event: event,
  )
  
  redirect to("/set_org?id=#{organization_id}")


end


post '/get_events' do

  organization_id = params[:organization_id]
  
  event_type = params[:event]
  today = DateTime.now.to_s
  last_month = DateTime.now.prev_month.to_s
  if params[:filter_actions] != ""
    actions = params[:filter_actions]
  else 
    actions = nil
  end

  if params[:filter_actors] != ""
    actors = params[:filter_actors]
  else
    actors = nil
  end

  if params[:filter_targets] != ""
      targets = params[:filter_targets]
  else
    targets = nil
  end

  if event_type == 'generate_csv'
    audit_log_export = WorkOS::AuditLogs.create_export(
      organization: organization_id,
      range_start: params[:range_start],
      range_end: params[:range_end],
      actions: actions,
      actors: actors,
      targets: targets
    )
    session[:export_id] = audit_log_export.id
    redirect to("/set_org?id=#{organization_id}")
  end
  
  if event_type == 'access_csv'
    export_id = session[:export_id].to_s
    audit_log_export = WorkOS::AuditLogs.get_export(
      id: export_id
    )
    url = audit_log_export.url

    redirect url
  end

end  
