require 'tempfile'

class ImagesController < ApplicationController
  before_filter :authenticate_user!, except: [:index]
  before_filter :check_user_permission, except: [:index]

  before_filter :set_user_id
  before_filter :set_image_id, :only => [:edit, :update, :destroy]

  before_filter :assemble_chunks, :only => [:plupload]

  def index
    @user = User.find_by_id(@user_id)
    if (@user.blank?)
      redirect_to root_path, notice: I18n.t('errors.absent_collection')
    else
      @images = @user.images

      @self_collection = (current_user.present? && (current_user.id.to_i == @user_id))
    end
  end

  def new
    @image = current_user.images.new
    @user = current_user
  end

  def create
    @image = Image.new(new_image_params)
    @image.user_id = @user_id

    if @image.save
      redirect_to user_images_path(@user_id)
    else
      redirect_to new_user_image_path(@user_id), notice: I18n.t('errors.images.create_error')
    end
  end

  def plupload
    # Если используются чунки, коллекционируем их до получения всех частей (может быть асинхронно) - в before_filter

    @image = Image.new(params.permit(:location, :title))
    @image.user_id = @user_id

    if @image.save
      redirect_to user_images_path(@user_id)
    else
      Rails.logger.info("Image load errors: #{@image.errors.full_messages.join('; ')}")
      redirect_to new_user_image_path(@user_id), notice: I18n.t('errors.images.create_error')
    end
  end

  def edit
    @image = Image.find(@image_id)
    @user = current_user
  end

  def update
    @image = Image.find(@image_id)

    # Обрабатываем тэги
    if params[:image][:tags].present?
      @tags = params[:image][:tags].split(',')
    end
    @tags ||= Array.new

    # Сначала удаляем отсутствующие в параметрах
    @image.image_tags.each do |image_tag|
      image_tag.destroy if !@tags.include?(image_tag.tag.name)
    end

    # Добавляем отсутствующие в базе
    @tags.each do |tag_name|
      tag = Tag.find_by_name(tag_name)
      tag = Tag.create(:name => tag_name) if tag.blank?
      @image.tags << tag if !@image.tags.include?(tag)
    end

    if @image.update_column(:title, params[:image][:title])
      redirect_to user_images_path(@user_id)
    else
      redirect_to new_user_image_path(@user_id), notice: I18n.t('errors.images.update_error')
    end
  end

  def destroy
    @image = Image.find(@image_id)
    @image.remove_location!
    @image.delete
    redirect_to user_images_path(@user_id)
  end

  private

  def set_user_id
    @user_id = params[:user_id].to_i
  end

  def set_image_id
    @image_id = params[:id].to_i
  end

  def new_image_params
    params.require(:image).permit(:user_id, :title, :location)
  end

  def assemble_chunks
    if (params[:chunks].present?)
      file_id = params[:name]
      chunks = chunks_get(file_id) || Array.new
      if !chunks.is_a?(Array)
        chunks = Array.new
      end

      # Отключаем финалайзер для временного файла
      ObjectSpace.undefine_finalizer(params[:file].tempfile)
      chunks[params[:chunk].to_i] = params[:file].tempfile.path

      # Проверяем собраны-ли все чунки
      chunks_count = (chunks.reject { |c| c.blank? }).count
      if chunks_count == params[:chunks].to_i
        Rails.logger.info("DBG: chunks = #{chunks.inspect}")
        chunks_set(file_id, Array.new)

        # Собираем один файл из отдельных чунков
        tmp_file = Tempfile.new('chunk')
        Rails.logger.info("DBG: result file = #{tmp_file.path}")
        chunks.each do |chunk_name|
          chunk = File.open(chunk_name)
          if tmp_file.write(chunk.read) > 0
            chunk.close
            File.unlink(chunk_name)
          end
        end

        mime_type = FileMagic.new(FileMagic::MAGIC_MIME).file(tmp_file.path)
        Rails.logger.info("DBG: detect mime type = #{mime_type}")

        location = ActionDispatch::Http::UploadedFile.new({
                                                              :filename => file_id,
                                                              :content_type => mime_type,
                                                              :tempfile => tmp_file
                                                          })
        params[:location] = location
        params[:title] = file_id
        true
      else
        chunks_set(file_id, chunks)
        render :nothing => true
        false
      end
    else
      params[:location] = params[:file]
      params[:title] = params[:name]
    end
  else
    true
  end

  def chunks_set(file_id, list)
    $redis.set("chunks_#{current_user.id}_#{file_id}", list.to_json)
  end

  def chunks_get(file_id)
    json = $redis.get("chunks_#{current_user.id}_#{file_id}")
    begin
      JSON.parse(json)
    rescue
      Array.new
    end
  end
end
