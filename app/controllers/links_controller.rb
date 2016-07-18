class LinksController < ApplicationController
    before_filter :authenticate_user!, except: [:index]
    before_filter :check_user_permission, except: [:index]

    before_filter :set_user_id
    before_filter :set_link_id, :only => [:edit, :update, :destroy]

    def index
        @links = @user.links

        @self_collection = (current_user.present? && (current_user.id.to_i == @user_id))
    end

    def new
        @link = Link.new
    end

    def create
        @link = Link.new(new_link_params)
        @link.user_id = @user_id

        if @link.save
            redirect_to user_links_path(@user_id)
        else
            redirect_to new_user_link_path(@user_id), notice: I18n.t('errors.links.create_error')
        end
    end

    def edit
    end

    def update
        if @link.update_attributes(edit_link_params)
            redirect_to user_links_path(@user_id)
        else
            redirect_to edit_user_link_path(@user_id, @link_id), notice: I18n.t('errors.links.update_error')
        end
    end

    def destroy
        @link = Link.find(@link_id)
        @link.delete
        redirect_to user_links_path(@user_id)
    end

    private

    def set_user_id
        @user_id = params[:user_id].to_i
        @user = User.find(@user_id)
    end

    def set_link_id
        @link_id = params[:id].to_i
        @link = Link.find(@link_id)
    end

    def new_link_params
        params.require(:link).permit(:user_id, :url, :name)
    end

    def edit_link_params
        params.require(:link).permit(:url, :name)
    end
end
