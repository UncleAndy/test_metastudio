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
end
