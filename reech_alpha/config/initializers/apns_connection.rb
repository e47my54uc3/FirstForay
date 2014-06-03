APNS.host = 'gateway.sandbox.push.apple.com' 
# gateway.sandbox.push.apple.com is default and only for development
# gateway.push.apple.com is only for production

APNS.port = 2195 
# this is also the default. Shouldn't ever have to set this, but just in case Apple goes crazy, you can.

path = File.join(Rails.root, "config/apple_push_notification_development.pem")
APNS.pem  = path

#APNS.pass = ''
# Just in case your pem need a password