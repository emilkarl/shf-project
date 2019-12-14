class CreateUserChecklists < ActiveRecord::Migration[5.2]
  def change
    create_table :user_checklists do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :ordered_list_entry, foreign_key: true
      t.datetime :date_completed, null: true

      t.timestamps
    end
  end
end
