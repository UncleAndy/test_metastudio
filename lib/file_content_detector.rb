# -*- encoding : utf-8 -*-
require 'mime/types'
require 'cocaine'

class FileContentDetector
  def initialize(filename)
    @file = filename
  end

  def media_type
    @media_type ||= set_media_type
  end

  def content_type
    @content_type ||= set_content_type
  end

  def image?
    media_type == :image
  end

  private

  def set_content_type
    begin
      cmd = Cocaine::CommandLine.new("file", "-b --mime-type :file")
      mime_type = cmd.run(file: @file.to_ascii)
      MIME::Type.new(mime_type).simplified
    rescue Cocaine::ExitStatusError => e
      Rails.logger.info("Error detection content type: #{e}")
      nil
    end
  end

  def set_media_type
    MIME::Type.new(content_type.to_s).media_type.to_sym

    rescue MIME::InvalidContentType
      :unknown
  end
end
