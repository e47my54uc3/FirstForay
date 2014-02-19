class UsersTable < ActiveRecord::Migration
  def up
  	create_table "users", :force => true do |t|
      t.string   "first_name"
      t.string   "last_name"
      t.string   "email",               :default => "",       :null => false
      t.datetime "created_at",                                :null => false
      t.datetime "updated_at",                                :null => false
      t.string   "profile_name",        :default => "beamer"
      t.string   "profile_id",                                :null => false
      t.string   "beamer_id",                                 :null => false
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
      t.text   "omniauth_data"
    end
    add_index "users", ["beamer_id"], :name => "index_users_on_beamer_id", :unique => true
    add_index "users", ["first_name"], :name => "index_users_on_first_name"
    add_index "users", ["profile_id"], :name => "index_users_on_profile_id", :unique => true
  end

  def down
    drop_table "users"
  end
end
