class CreateOrderedListEntries < ActiveRecord::Migration[5.2]

  def change
    create_table :ordered_list_entries do |t|
      t.string :name
      t.string :description
      t.integer :list_position
      t.string :ancestry

      t.timestamps
    end

    add_index :ordered_list_entries, :ancestry
    add_index :ordered_list_entries, :name

  end
end
