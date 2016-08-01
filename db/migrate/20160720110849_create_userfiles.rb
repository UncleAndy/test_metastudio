class CreateUserfiles < ActiveRecord::Migration
  def change
    create_table :userfiles do |t|
      t.integer :user_id
      t.string :title
      t.string :location
      t.string :mimetype

      t.timestamps null: false
    end
    add_index :userfiles, :user_id
  end
end
