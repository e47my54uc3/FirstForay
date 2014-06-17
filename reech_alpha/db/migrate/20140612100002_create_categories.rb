class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :title

      t.timestamps
    end
    Category.create(:title => "News")
    Category.create(:title => "Sports")
    Category.create(:title => "Entertainment")
  end
end
