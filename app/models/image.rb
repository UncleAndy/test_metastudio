class Image < ActiveRecord::Base
  # :title, :location, :user_id

  mount_uploader :location, ImageUploader

  belongs_to :user
  has_many :image_tags
  has_many :tags, through: :image_tags

  default_scope { order('created_at DESC') }

  def random_string
    @randomstring ||= SecureRandom.hex(10)
  end


  def set_tags(tags_list)
    # Сначала удаляем отсутствующие
    self.image_tags.each do |image_tag|
      image_tag.destroy if !tags_list.include?(image_tag.tag.name)
    end

    # Добавляем отсутствующие в базе
    tags_list.each do |tag_name|
      tag = Tag.find_by_name(tag_name)
      tag = Tag.create(:name => tag_name) if tag.blank?
      self.tags << tag if !self.tags.include?(tag)
    end
  end
end
