# frozen_string_literal: true
class Users::SessionsController < Devise::SessionsController

  # Define WorkOS API key and Client ID from environment variables
  WorkOS.key = ENV['WORKOS_API_KEY']
  CLIENT_ID = ENV['WORKOS_CLIENT_ID']

  # Set the Organization ID that you want to test
  ORGANIZATION_ID = 'CHANGE TO YOUR ORGANIZATION'

  # GET /sso/new path to authenticate via WorkOS
  # You can also use connection or provider parameters
  # in place of the domain parameter
  # https://workos.com/docs/reference/sso/authorize/get
  def auth
    login_type = params[:login_method]
    params = {
      client_id: CLIENT_ID,
      redirect_uri: ENV['WORKOS_REDIRECT_URI'],
      state: ""
    }
  
    if login_type == 'saml'
      params[:organization] = ORGANIZATION_ID
    else
      params[:provider] = login_type
    end
  
    authorization_url = WorkOS::SSO.authorization_url(**params)
    redirect_to authorization_url
  end

  # GET /sso/callback path to consume profile object from WorkOS
  def callback
    profile_and_token = WorkOS::SSO.profile_and_token(
      code: params['code'],
      client_id: CLIENT_ID,
    )
    @user = User.from_sso(profile_and_token.profile)
    @user.save
    puts User.all
    sign_in_and_redirect @user
  end

  # Send user to root path after authenticating
  def after_sign_in_path_for(_resource)
    root_path
  end

  def destroy
    sign_out_and_redirect(current_user)
  end
end
