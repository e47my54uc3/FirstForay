ThinkingSphinx::Index.define :category, :with => :active_record do
  indexes title, enable_star: true
  indexes created_at
end
