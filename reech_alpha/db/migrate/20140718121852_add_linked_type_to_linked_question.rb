class AddLinkedTypeToLinkedQuestion < ActiveRecord::Migration
  def change
    add_column :linked_questions, :linked_type, :string, after: :linked_by_uid ,:limit => 7
    add_column :linked_questions, :status, :boolean, after: :linked_type ,:default => 1
  end
end
