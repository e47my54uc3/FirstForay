class UserSettings < ActiveRecord::Base
  attr_accessible :emailnotif_is_enabled, :location_is_enabled, :notify_linked_to_question, :notify_question_when_answered, :notify_solution_got_highfive, :pushnotif_is_enabled

  belongs_to :user,:primary_key=>:reecher_id,:foreign_key=>:reecher_id


end
