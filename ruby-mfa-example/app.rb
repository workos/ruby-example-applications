# frozen_string_literal: true

require 'dotenv/load'
require 'sinatra'
require 'workos'
require 'json'

use Rack::Session::Pool

# Pull API key from ENV variable
WorkOS.key = ENV['WORKOS_API_KEY']

get '/' do
  if session[:factor_list].nil?
    session[:factor_list] ||= []
    @factors = session[:factor_list] 
    session[:current_factor_qr] = ''
    session[:phone_number] = ''
    erb :index, :layout => :layout
  else
    @factors=session[:factor_list]
    erb :index, :layout => :layout
  end
end


get '/enroll_factor_details' do
  erb :enroll_factor, :layout => :layout
end

post '/enroll_sms_factor' do
  factor_type = params[:type]
  phone_number = params[:phone_number]

  new_factor = WorkOS::MFA.enroll_factor(
    type: factor_type,
    phone_number: phone_number,
    )
  session[:factor_list] << new_factor 
  @factors = session[:factor_list]
  redirect '/'
end

post '/enroll_totp_factor' do
  request.body.rewind
  parsed_body = JSON.parse(request.body.read)
  (type, issuer, user) = parsed_body.values_at('type', 'issuer', 'user')

  new_factor = WorkOS::MFA.enroll_factor(
    type: type,
    totp_issuer: issuer,
    totp_user: user
  )
  session[:factor_list] << new_factor 
  @factors = session[:factor_list]

  return issuer
end

get '/factor_detail' do
  factors = session[:factor_list]
  @factor  = factors.select {|factor| factor.id == params[:id] }.first
  if @factor.type == 'sms'
    @phone_number = @factor .sms[:phone_number]
    session[:phone_numer] = @phone_number
  elsif  @factor.type == 'totp' 
    @current_factor_qr = @factor.totp[:qr_code]
    session[:current_factor_qr] = @current_factor_qr
  end
  session[:current_factor] = @factor.id
  session[:current_factor_type] = @factor.type
  erb :factor_detail, :layout => :layout
end

post '/challenge_factor' do
  if session[:current_factor_type] == 'sms'
    message = params[:sms_message]
    session[:message] = message
    challenge = WorkOS::MFA.challenge_factor(
      authentication_factor_id: session[:current_factor],
      sms_template: message,
    )
  else
    challenge = WorkOS::MFA.challenge_factor(
      authentication_factor_id: session[:current_factor],
    )
  end
  session[:challenge_id] = challenge.id

  erb :challenge_factor, :layout => :layout
end

post '/verify_factor' do
  code = params[:code]
  challenge_id = session[:challenge_id]
  verify_factor = WorkOS::MFA.verify_factor(
    authentication_challenge_id: challenge_id,
    code: code
  )
  @challenge = verify_factor.challenge
  @valid = verify_factor.valid
  @type = session[:type]
  erb :challenge_success, :layout => :layout
end

get '/clear_session' do
  session.clear
  redirect '/'
end