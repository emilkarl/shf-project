class AddAncestryToChecklists < ActiveRecord::Migration[5.2]
  def change
    add_column :checklists, :ancestry, :string
    add_index :checklists, :ancestry
  end
end
