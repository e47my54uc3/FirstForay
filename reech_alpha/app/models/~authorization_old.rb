class Authorization < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user_id, :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider

  def self.find_from_omniauth_data(hash)
    find_by_provider_and_uid(hash['provider'], hash['uid'])
  end

  def self.create_from_omniauth_data(hash, user = nil)
    user ||= User.create_from_omniauth_data(hash)
    Authorization.create(:user_id => user.id, :uid => hash['uid'], :provider => hash['provider'])
  end
end