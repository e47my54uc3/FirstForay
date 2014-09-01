# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)

# CreateCategories 
Category.create(:title => "News")
Category.create(:title => "Sports")
Category.create(:title => "Entertainment")

# InsertCategoryTocategoryMasterTable
Category.create([{:title => "Arts & Culture"},
    {:title => "Community Events"},
    {:title => "Education"},
    {:title => "Family & Pets"},
    {:title => "Food & Dining"},
    {:title => "Health"},
    {:title => "Home Improvement"},
    {:title => "Personal Services"},
    {:title => "Professional Services"},
    {:title => "Real Estate"},
    {:title => "Arts & Culture"},
    {:title => "Sports & Rec"},
    {:title => "Technology"},
    {:title => "Other"}])