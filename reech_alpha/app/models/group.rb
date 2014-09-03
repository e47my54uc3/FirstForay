class Group < ActiveRecord::Base

  has_and_belongs_to_many :members, class_name: "User", join_table: "groups_users"
  attr_accessor :member_reecher_ids
  attr_accessible :name, :reecher_id, :member_reecher_ids, :member_ids

  belongs_to :user, primary_key: 'reecher_id', foreign_key: 'reecher_id'
  validates :name, uniqueness: { :scope => [:reecher_id], :case_sensitive => false, :message => "Group name has already been taken"}

  before_validation :load_members
  validate :check_members

  def load_members
    # This is because the join table stores user.id and group is associated via reecher_id.
    self.member_ids = User.where(reecher_id: member_reecher_ids).collect(&:id) if member_reecher_ids
  end

  def check_members
    #Important check. Don't add if not friends with group owner!
    errors.add(:member, 'Some members are not friends of the owner') if !(self.member_ids - user.friends.collect(&:id)).empty?
  end

end
