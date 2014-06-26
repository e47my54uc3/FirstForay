class InsertCategoryTocategoryMasterTable < ActiveRecord::Migration
  def change
    Category.destroy_all 
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
  end
  
end
