class AddColumnStatusToInviteUser < ActiveRecord::Migration
  def change
     add_column :invite_users, :status, :boolean, after: :referral_code ,:default => 1
  end
end
