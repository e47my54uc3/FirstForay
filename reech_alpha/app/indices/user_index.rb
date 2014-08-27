ThinkingSphinx::Index.define :user, :with => :active_record do
  indexes [first_name, last_name], as: :name, enable_star: true
  indexes :email
  indexes created_at
end
