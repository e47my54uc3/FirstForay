# Load the rails application
require File.expand_path('../application', __FILE__)
require 'ancestry'
require 'thread'

GRAPH_APP_ID = '441561109304421'
GRAPH_SECRET = '3bc0610bd034f778d8c73d88ba39e417'

# Initialize the rails application
Socialbeam::Application.initialize!


