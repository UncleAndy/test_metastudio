class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.integer :user_id
      t.string :name, null: false
      t.string :url, null: false

      t.timestamps null: false
    end

    add_index :links, :user_id
  end
end
