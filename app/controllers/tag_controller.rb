class TagController < ApplicationController
  def index
    @tags_by_model = Taggable.tags_by_class
  end

  def show
  end

  def edit
  end

  def update
  end

  private

  def tag_name
    params[:id]
  end
end
