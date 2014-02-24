class SolutionTable < ActiveRecord::Migration
  def up
  	create_table "solutions", :force => true do |t|
	    t.string   "solver_id"
	    t.string   "solver"
	    t.text     "body",                        :null => false
	    t.integer  "ask_charisma", :default => 5
	    t.integer  "ups",          :default => 0
	    t.integer  "downs",        :default => 0
	    t.string   "question_id"
	    t.string   "linked_user"
	    t.datetime "created_at",                  :null => false
	    t.datetime "updated_at",                  :null => false
	  end
  end

  def down
  	drop_table "solutions"
  end
end
