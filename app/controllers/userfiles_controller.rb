require 'tempfile'

class UserfilesController < ApplicationController
  before_filter :authenticate_user!, except: [:index]
  before_filter :check_user_permission, except: [:index]

  before_filter :set_user
  before_filter :set_file, :only => [:edit, :update, :destroy, :preview, :download]

  before_filter :assemble_chunks, :only => [:plupload]

  def index
    if (@user.blank?)
      redirect_to root_path, notice: I18n.t('errors.absent_collection')
    else
      @files = @user.files

      @self_collection = (current_user.present? && (current_user.id.to_i == @user_id))
    end
  end

  def new
    @file = current_user.files.new
    @user = current_user
  end

  def create
    @file = Userfile.new(new_file_params)
    @file.user_id = @user_id

    if @file.save
      redirect_to user_userfiles_path(@user_id)
    else
      redirect_to new_user_userfile_path(@user_id), notice: I18n.t('errors.files.create_error')
    end
  end

  def plupload
    # Если используются чунки, коллекционируем их до получения всех частей (может быть асинхронно) - в before_filter

    @file = Userfile.new(params.permit(:location, :title))

    @file.content_type = @mime_type if @mime_type.present?
    @file.file_type = @type_detector.type.to_s if @type_detector.present?
    @file.file_size = @file_size if @file_size.present?
    @file.filename = @filename if @filename.present?
    @file.user_id = @user_id

    Rails.logger.info("DBG: Saved file = #{@file.inspect}")

    if @file.save
      if params[:tags].present?
        @tags = params[:tags].split(',')
      end
      @tags ||= Array.new

      @file.set_tags(@tags)

      Rails.logger.info("DBG: File after save = #{@file.inspect}")

      redirect_to user_userfiles_path(@user_id)
    else
      Rails.logger.info("File load errors: #{@file.errors.full_messages.join('; ')}")
      redirect_to new_user_userfile_path(@user_id), notice: I18n.t('errors.files.create_error')
    end
  end

  def edit
    @user = current_user
  end

  def update
    if params[:userfile][:tags].present?
      @tags = params[:userfile][:tags].split(',')
    end
    @tags ||= Array.new

    @file.set_tags(@tags)

    if @file.update_column(:title, params[:userfile][:title])
      redirect_to user_userfiles_path(@user_id)
    else
      redirect_to new_user_userfile_path(@user_id), notice: I18n.t('errors.files.update_error')
    end
  end

  def destroy
    @file.remove_location!
    @file.delete
    redirect_to user_userfiles_path(@user_id)
  end

  def preview
    if @file.file_type == 'image'
      redirect_to @file.location_url(:preview)
    elsif @file.file_type == 'video'
      redirect_to Settings.files.video_preview_path
    else
      redirect_to Settings.files.file_preview_path
    end
  end

  def download
    send_file @file.location.path, :disposition => "attachment", :filename => @file.filename, :length => @file.file_size
  end

  private

  def set_user
    @user_id = params[:user_id].to_i
    @user = User.find(@user_id)
  end

  def set_file
    @file_id = params[:id].to_i
    @file = Userfile.find(@file_id)
  end

  def new_file_params
    params.require(:userfile).permit(:user_id, :title, :location)
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

        @mime_type = FileMagic.new(FileMagic::MAGIC_MIME).file(tmp_file.path)

        location = ActionDispatch::Http::UploadedFile.new({
                                                              :filename => file_id,
                                                              :content_type => @mime_type,
                                                              :tempfile => tmp_file
                                                          })

        @filename = file_id
        @type_detector = ::FileTypeDetector.new(tmp_file.path)
        @file_size = tmp_file.size

        Rails.logger.info("DBG: filename = #{@filename}")
        Rails.logger.info("DBG: mime_type = #{@mime_type}")
        Rails.logger.info("DBG: type = #{@type_detector.type}")

        params[:location] = location
        true
      else
        chunks_set(file_id, chunks)
        render :nothing => true
        false
      end
    else
      params[:location] = params[:file]
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
