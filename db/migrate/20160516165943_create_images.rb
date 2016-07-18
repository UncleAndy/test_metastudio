class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.integer :user_id
      t.string :title
      t.string :location

      t.timestamps null: false
    end
    add_index :images, :user_id
  end
end
