# frozen_string_literal: true

require 'dotenv/load'
require 'sinatra'
require 'workos'
require 'json'

# Pull API key from ENV variable
WorkOS.key = ENV['WORKOS_API_KEY']

# Configure your Redirect URIs on the dashboard configuration
# page: https://dashboard.workos.com/sso/configuration
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
  @email = session[:email]
  print(@email, 'email at /')
  erb :index, :layout => :layout
end

post '/passwordless-auth' do
  session = WorkOS::Passwordless.create_session(
    email: params[:email],
    type: 'MagicLink',
    redirect_uri: REDIRECT_URI
  )
  WorkOS::Passwordless.send_session(session.id)

  redirect '/check-email'
end

get '/check-email' do
  erb :check_email, :layout => :layout
end

get '/callback' do
  profile_and_token = WorkOS::SSO.profile_and_token(
    code: params['code'],
    client_id: ENV['WORKOS_CLIENT_ID'],
  )

  session[:user] = profile_and_token.profile.to_json
  session[:email] = profile_and_token.profile.email
  
  redirect '/'
end

get '/logout' do
  session[:user] = nil

  redirect '/'
end
