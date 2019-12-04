class CreateChecklists < ActiveRecord::Migration[5.2]

  def change

    create_table :checklists do |t|
      t.string :name
      t.string :description
      t.string :ancestry

      t.timestamps
    end

    add_index :checklists, :ancestry

  end
end
