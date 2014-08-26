ThinkingSphinx::Index.define :category, :with => :active_record do
  indexes title
  indexes created_at
end
