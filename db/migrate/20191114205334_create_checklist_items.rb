class CreateChecklistItems < ActiveRecord::Migration[5.2]
  def change
    create_table :checklist_items do |t|
      t.string :title, null: false
      t.string :description
      t.boolean :complete, default: false
      t.timestamp :date_completed, null: true, comment: 'this might have a value even if complete is false.  Whatever the complete column says is the truth about whether this is complete or not.'

      t.timestamps
    end
  end
end
