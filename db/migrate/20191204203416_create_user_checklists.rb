class CreateUserChecklists < ActiveRecord::Migration[5.2]

  def change
    create_table :user_checklists do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :ordered_list_entry, foreign_key: true
      t.datetime :date_completed, null: true
      t.string :ancestry
      t.integer :list_position, null: false, comment: 'This is zero-based. It is the order (position) that this item should appear in its checklist'

      t.timestamps
    end

    add_index :user_checklists, :ancestry
  end
end
