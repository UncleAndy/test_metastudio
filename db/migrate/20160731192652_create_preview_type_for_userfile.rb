class CreatePreviewTypeForUserfile < ActiveRecord::Migration
  def change
    change_table :userfiles do |t|
      t.string :preview_type, :default => 'none'
      t.string :filename
      t.string :file_type
      t.string :content_type
      t.integer :file_size
    end
  end
end
