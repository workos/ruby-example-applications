# frozen_string_literal: true
class Users::SessionsController < Devise::SessionsController

  # Define WorkOS API key and Client ID from environment variables
  WorkOS.key = ENV['WORKOS_API_KEY']
  CLIENT_ID = ENV['WORKOS_CLIENT_ID']

  # Set the Connection ID that you want to test
  CONNECTION_ID = 'conn_01FHQ0G8Q6WTP0YT1E3CVNQD6V'

  # GET /sso/new path to authenticate via WorkOS
  # You can also use connection or provider parameters
  # in place of the domain parameter
  # https://workos.com/docs/reference/sso/authorize/get
  def auth
    authorization_url = WorkOS::SSO.authorization_url(
      connection: CONNECTION_ID,
      client_id: CLIENT_ID,
      redirect_uri: ENV['WORKOS_REDIRECT_URI'],
    )

    redirect_to authorization_url
  end

  # GET /sso/callback path to consume profile object from WorkOS
  def callback
    profile_and_token = WorkOS::SSO.profile_and_token(
      code: params['code'],
      client_id: CLIENT_ID,
    )

    @user = User.from_sso(profile_and_token.profile)

    sign_in_and_redirect @user
  end

  # Send user to root path after authenticating
  def after_sign_in_path_for(_resource)
    root_path
  end

  def destroy
    if current_user
      puts current_user.id
      session.delete(current_user.id)
      flash[:success] = 'Goodbye!'
    end
    redirect_to root_path
  end
end
