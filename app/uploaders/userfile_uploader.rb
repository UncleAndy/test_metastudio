# -*- encoding : utf-8 -*-

require 'file_type_detector'

class UserfileUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick
  include CarrierWave::MimeTypes

  process :set_content_type

  def store_dir
    "files/#{model.user_id}"
  end

  version :preview, :if => :is_image? do
    process :resize_to_fit => [128, 128]
  end

  def filename
    "#{model.random_string}#{File.extname(original_filename)}"
  end

  def is_image? (file)
    file.content_type =~ /^image/
  end
end
