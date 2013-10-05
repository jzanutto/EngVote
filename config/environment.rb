# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
EngVote::Application.initialize!

require 'casclient'
require 'casclient/frameworks/rails/filter'

CASClient::Frameworks::Rails::Filter.configure(
  :cas_base_url => 'https://cas-dev.uwaterloo.ca/cas',
  :username_session_key => :cas_user,
  :extra_attributes_session_key => :cas_extra_attributes
)
