class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  serialize :raw_attributes

  def self.from_sso(profile)
    where(provider: profile.connection_type, uid: profile.id).first_or_create do |user|
      user.email = profile.email
      user.password = Devise.friendly_token[0, 20]
      user.first_name = profile.first_name
      user.last_name = profile.last_name
      user.raw_attributes = profile.raw_attributes
    end
  end
end
