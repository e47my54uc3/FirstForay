# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140228091025) do

  create_table "api_keys", :force => true do |t|
    t.string   "access_token"
    t.string   "user_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "authorizations", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "badges_sashes", :force => true do |t|
    t.integer  "badge_id"
    t.integer  "sash_id"
    t.boolean  "notified_user", :default => false
    t.datetime "created_at"
  end

  add_index "badges_sashes", ["badge_id", "sash_id"], :name => "index_badges_sashes_on_badge_id_and_sash_id"
  add_index "badges_sashes", ["badge_id"], :name => "index_badges_sashes_on_badge_id"
  add_index "badges_sashes", ["sash_id"], :name => "index_badges_sashes_on_sash_id"

  create_table "chats", :force => true do |t|
    t.string   "broadcasted_by"
    t.string   "broadcasted_to"
    t.text     "message"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "chats", ["broadcasted_by", "broadcasted_to"], :name => "index_chats_on_broadcasted_by_and_broadcasted_to"
  add_index "chats", ["broadcasted_by"], :name => "index_chats_on_broadcasted_by"
  add_index "chats", ["broadcasted_to"], :name => "index_chats_on_broadcasted_to"

  create_table "friendships", :force => true do |t|
    t.string   "reecher_id"
    t.string   "friend_reecher_id"
    t.string   "status"
    t.datetime "created_at"
  end

  create_table "merit_actions", :force => true do |t|
    t.integer  "user_id"
    t.string   "action_method"
    t.integer  "action_value"
    t.boolean  "had_errors",    :default => false
    t.string   "target_model"
    t.integer  "target_id"
    t.boolean  "processed",     :default => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "merit_activity_logs", :force => true do |t|
    t.integer  "action_id"
    t.string   "related_change_type"
    t.integer  "related_change_id"
    t.string   "description"
    t.datetime "created_at"
  end

  create_table "merit_score_points", :force => true do |t|
    t.integer  "score_id"
    t.integer  "num_points", :default => 0
    t.string   "log"
    t.datetime "created_at"
  end

  create_table "merit_scores", :force => true do |t|
    t.integer "sash_id"
    t.string  "category", :default => "default"
  end

  create_table "messages", :force => true do |t|
    t.string   "subject"
    t.text     "body"
    t.integer  "user_id"
    t.string   "ancestry"
    t.string   "recipient_ids"
    t.datetime "sent_at"
    t.datetime "received_at"
    t.datetime "read_at"
    t.datetime "trashed_at"
    t.datetime "deleted_at"
    t.boolean  "editable",      :default => true
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "messages", ["ancestry"], :name => "index_messages_on_ancestry"
  add_index "messages", ["user_id"], :name => "index_messages_on_user_id"

  create_table "newsfeeds", :force => true do |t|
    t.string   "verb"
    t.string   "activity"
    t.string   "actor_id"
    t.string   "actor_type"
    t.string   "actor_name_method"
    t.string   "indirect_actor_id"
    t.string   "indirect_actor_type"
    t.string   "indirect_actor_name_method"
    t.integer  "count",                      :default => 1
    t.string   "object_id"
    t.string   "object_type"
    t.string   "object_name_method"
    t.integer  "privacystatus",              :default => 0
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  create_table "purchased_solutions", :force => true do |t|
    t.string   "user_id"
    t.string   "solution_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "questions", :force => true do |t|
    t.string   "post"
    t.string   "posted_by"
    t.string   "posted_by_uid"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "ups"
    t.integer  "downs"
    t.string   "question_id",                  :null => false
    t.integer  "sash_id"
    t.integer  "level",         :default => 0
    t.integer  "Charisma"
  end

  create_table "sashes", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

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

  create_table "user_profiles", :force => true do |t|
    t.string "reecher_id"
    t.text   "reecher_interests"
    t.text   "reecher_hobbies"
    t.text   "reecher_fav_music"
    t.text   "reecher_fav_movies"
    t.text   "reecher_fav_books"
    t.text   "reecher_fav_sports"
    t.text   "reecher_fav_destinations"
    t.text   "reecher_fav_cuisines"
    t.text   "bio"
    t.string "snippet"
  end

  add_index "user_profiles", ["reecher_id"], :name => "index_user_profiles_on_reecher_id"

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email",               :default => "",        :null => false
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.string   "profile_name",        :default => "reecher"
    t.string   "profile_id",                                 :null => false
    t.string   "reecher_id",                                 :null => false
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.string   "single_access_token"
    t.integer  "login_count",         :default => 0
    t.integer  "failed_login_count",  :default => 0
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.text     "omniauth_data"
    t.integer  "sash_id"
    t.integer  "level",               :default => 0
  end

  add_index "users", ["first_name"], :name => "index_users_on_first_name"
  add_index "users", ["profile_id"], :name => "index_users_on_profile_id", :unique => true
  add_index "users", ["reecher_id"], :name => "index_users_on_reecher_id", :unique => true

end
