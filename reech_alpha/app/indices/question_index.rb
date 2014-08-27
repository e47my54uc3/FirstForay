ThinkingSphinx::Index.define :question, :with => :active_record do
  indexes post, enable_star: true
  indexes posted_by, enable_star: true
end
