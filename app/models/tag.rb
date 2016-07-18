class Tag < ActiveRecord::Base
  # name

  has_many :image_tags
  has_many :images, through: :image_tags

  scope :by_name, ->(n) { where('name ilike ?', "#{n}%") }
end
