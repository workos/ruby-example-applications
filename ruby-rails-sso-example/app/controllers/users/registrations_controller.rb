# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    root_path
  end
end
