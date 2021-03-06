# Testing app setup

##################
# Database schema
##################

ActiveRecord::Migration.suppress_messages do
  ActiveRecord::Schema.define(:version => 0) do
    create_table :users, :force => true do |t|
      t.column "type", :string
    end
    
    create_table :posts, :force => true do |t|
      t.column "author_id", :integer
      t.column "category_id", :integer
      t.column "inflamatory", :boolean
    end

    create_table :categories, :force => true do |t|
    end

    create_table :solutions, :force => true do |t|
      t.column "user_id", :integer
      t.column "post_id", :integer
    end
  end
end

#########
# Models
#
# Domain model is this:
#
#   - authors (type of user) can create posts in categories
#   - users can solution on posts
#   - authors have similar_posts: posts in the same categories as ther posts
#   - authors have similar_authors: authors of the recommended_posts
#   - authors have posts_of_similar_authors: all posts by similar authors (not just the similar posts,
#                                            similar_posts is be a subset of this collection)
#   - authors have solvers: users who have solved on their posts
#
class User < ActiveRecord::Base
  has_many :solutions
  has_many :solved_posts, :through => :solutions, :source => :post, :uniq => true
  has_many :solved_authors, :through => :solved_posts, :source => :author, :uniq => true
  has_many :posts_of_interest, :through => :solved_authors, :source => :posts_of_similar_authors, :uniq => true
  has_many :categories_of_interest, :through => :posts_of_interest, :source => :category, :uniq => true
end

class Author < User
  has_many :posts
  has_many :categories, :through => :posts
  has_many :similar_posts, :through => :categories, :source => :posts
  has_many :similar_authors, :through => :similar_posts, :source => :author, :uniq => true
  has_many :posts_of_similar_authors, :through => :similar_authors, :source => :posts, :uniq => true
  has_many :solvers, :through => :posts, :uniq => true
end

class Post < ActiveRecord::Base
  
  # testing with_scope
  def self.find_inflamatory(*args)
    with_scope :find => {:conditions => {:inflamatory => true}} do
      find(*args)
    end
  end

  # only test named_scope in edge
  named_scope(:inflamatory, :conditions => {:inflamatory => true}) if respond_to?(:named_scope)
  
  belongs_to :author
  belongs_to :category
  has_many :solutions
  has_many :solvers, :through => :solutions, :source => :user, :uniq => true
end

class Category < ActiveRecord::Base
  has_many :posts
end

class Solution < ActiveRecord::Base
  belongs_to :user
  belongs_to :post
end