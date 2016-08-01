class CreateUserfileTags < ActiveRecord::Migration
  def change
    create_table :userfile_tags do |t|
      t.integer :userfile_id
      t.integer :tag_id

      t.timestamps null: false
    end

    add_index :userfile_tags, [:userfile_id, :tag_id], unique: true
    add_index :userfile_tags, :tag_id
  end
end
