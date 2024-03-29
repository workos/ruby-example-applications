# frozen_string_literal: true

require 'dotenv/load'
require 'sinatra'
require 'workos'
require 'json'

# Pull API key from ENV variable
WorkOS.key = ENV['WORKOS_API_KEY']

# Input your organization ID from your WorkOS dashboard
# Configure your Redirect URIs on the dashboard
# configuration page.
ORGANIZATION_ID = ENV['WORKOS_ORGANIZATION_ID']
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
  @current_user = session[:user] && JSON.pretty_generate(session[:user])
  @first_name = session[:first_name]
  erb :index, :layout => :layout
end

# Authenticate a user by sending them to the WorkOS API
# https://workos.com/docs/reference/sso/authorize/get
post '/auth' do
  login_type = params[:login_method]
  params = {
    client_id: CLIENT_ID,
    redirect_uri: REDIRECT_URI,
    state: ""
  }

  if login_type == 'saml'
    params[:organization] = ORGANIZATION_ID
  else
    params[:provider] = login_type
  end

  authorization_url = WorkOS::SSO.authorization_url(**params)
  redirect authorization_url
end



# Exchange a code for a user profile at the callback route
get '/callback' do

  profile_and_token = WorkOS::SSO.profile_and_token(
    code: params['code'],
    client_id: ENV['WORKOS_CLIENT_ID'],
  )
  profile = profile_and_token.profile
  session[:user] = profile.to_json
  session[:first_name] = profile.first_name

  redirect '/'
end

# Logout a user
get '/logout' do
  session[:user] = nil

  redirect '/'
end