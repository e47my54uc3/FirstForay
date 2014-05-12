# Model for maintain device tokens to send push notifications 
class Device < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user, :foreign_key => "reecher_id"
end
