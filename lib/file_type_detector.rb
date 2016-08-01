# -*- encoding : utf-8 -*-

require 'file_content_detector'

class FileTypeDetector
  def initialize(filename)
    @file = filename
  end

  def image?
    media_type == :image
  end

  def video?
    media_type == :video
  end

  def audio?
    media_type == :audio
  end

  def application?
    media_type == :application
  end

  def valid?
    validate_type
  end

  def type
    media_type
  end

  def content_type
    @content_type ||= set_content_type
  end

  private

  def media_type
    @media_type ||= set_media_type
  end

  # Файл может иметь несколько типов.
  # Например, .mp4 файл - [application/mp4, audio/mp4, video/mp4, video/vnd.objectvideo].
  def set_content_type
    types = MIME::Types.type_for(@file)
    return types.first.simplified if types.size == 1

    real_type = content_detector.content_type
    index = types.index { |type| type.simplified == real_type }

    if index.present?
      types[index].simplified
    elsif types.present?
      types.first.simplified
    elsif real_type.present?
      real_type
    end
  end

  def set_media_type
    case (type = MIME::Type.new(content_type.to_s).media_type)
      when 'audio', 'video', 'image', 'application'
        type.to_sym
      when 'text'
        :application
      else
        :unknown
    end
  rescue MIME::Type::InvalidContentType
    :unknown
  end

  def validate_type
    case(media_type)
      when :audio, :video, :image
        content_detector.content_type == content_type
      when :application
        [:application, :text].include?(content_detector.media_type)
      when :unknown
        false
      else
        false
    end
  end

  def content_detector
    @content_detector ||= FileContentDetector.new(@file)
  end
end
