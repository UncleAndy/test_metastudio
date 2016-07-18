class TagsController < ApplicationController
  def index
    search_str = params[:term]
    if search_str.present?
      search_str = search_str.gsub(/^\s+/, '')
      search_str = search_str.gsub(/\s+$/, '')
      tags = Tag.select('id, name').by_name(search_str).all
    else
      tags = Tag.select('id, name').all
    end

    tags_list = Array.new
    tags.each do |tag|
      tags_list.push({:label => tag.name})
    end

    render :json => tags_list
  end
end
