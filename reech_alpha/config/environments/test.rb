Reech::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Configure static asset server for tests with Cache-Control for performance
  config.serve_static_assets = true
  config.static_cache_control = "public, max-age=3600"

  # Log error messages when you accidentally call methods on nil
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr
  
# Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  #required by devise. Set host to correct host in production mode

  config.action_mailer.default_url_options = { :host => 'ec2-54-201-116-44.us-west-2.compute.amazonaws.com:3000' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
  address:              'smtp.gmail.com',
  port:                 587,
  domain:               'gmail.com',
  user_name:            'hello@reechout.co',
  password:             'Superhelper1!',
  authentication:       'login',
  enable_starttls_auto: true  }

  config.paperclip_defaults = {
  :storage => :s3,
  :s3_credentials => {
    :bucket => 'reechattachmentstorage',
    :access_key_id => 'AKIAIVK7XM7Q7YX72IDQ',
    :secret_access_key => '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'
    
  },
  :s3_multipart_min_part_size => 20971520
 }
  
  
end
