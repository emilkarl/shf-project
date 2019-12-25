class CreateOrderedListEntries < ActiveRecord::Migration[5.2]

  def change
    create_table :ordered_list_entries do |t|
      t.string :name, null: false
      t.string :description
      t.integer :list_position, null: false, comment: 'This is zero-based. It is the order (position) that this item should appear in its checklist'
      t.string :ancestry

      t.timestamps
    end

    add_index :ordered_list_entries, :ancestry
    add_index :ordered_list_entries, :name
  end
end
