require 'omniauth-openid'
require 'openid/store/filesystem'

Rails.application.config.middleware.use OmniAuth::Builder do
	#provider :developer unless Rails.env.production?
    provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
    provider :facebook, GRAPH_APP_ID, GRAPH_SECRET
    provider :linkedin, ENV['LINKEDIN_KEY'], ENV['LINKEDIN_SECRET']
    provider :open_id, :store => OpenID::Store::Filesystem.new('/tmp')
    # Mention other providers here you want to allow user to sign in with
end
