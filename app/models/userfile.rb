class Userfile < ActiveRecord::Base
  # :title, :location, :user_id, :mimetype, :preview_type
  mount_uploader :location, UserfileUploader

  belongs_to :user
  has_many :userfile_tags
  has_many :tags, through: :userfile_tags

  default_scope { order('created_at DESC') }

  def random_string
    @randomstring ||= SecureRandom.hex(10)
  end

  def set_tags(tags_list)
    # Сначала удаляем отсутствующие
    self.userfile_tags.each do |tag|
      tag.destroy if !tags_list.include?(tag.tag.name)
    end

    # Добавляем отсутствующие в базе
    tags_list.each do |tag_name|
      tag = Tag.find_by_name(tag_name)
      tag = Tag.create(:name => tag_name) if tag.blank?
      self.tags << tag if !self.tags.include?(tag)
    end
  end
end
