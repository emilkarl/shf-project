class CreateChecklistItems < ActiveRecord::Migration[5.2]
  def change
    create_table :checklist_items do |t|
      t.string :name, null: false
      t.string :description
      t.belongs_to :checklist,  foreign_key: true
      t.integer :order_in_list, null: false, comment: 'This is zero-based. It is the order (positi.on) that this item should appear in its checklist'

      t.timestamps
    end

  end
end
