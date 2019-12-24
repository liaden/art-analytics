# frozen_string_literal: true

class TagsController < ApplicationController
  def index
    search = SearchTags.on(*requested_resources)
    @tag_results = search.with_prefix(tag_prefix).transform_keys!{ |r| Taggable.resource(r) }

    respond_to do |format|
      format.html
      format.json { render json: search.with_prefix(tag_prefix).to_json }
    end
  end

  def show
    @tag = Tag.new(params.permit(:id, :resource, :resources))

    respond_to do |format|
      format.html
      format.json { render json: @tag.to_json }
    end
  end

  def create
  end

  def update
  end

  def destroy
  end

  private

  def requested_resources
    (params.fetch(:resources, []) + Array(params[:resource])).uniq
  end

  def tag_params
    params.permit(:resource, :resources, :tag_prefix)
  end

  def tag_prefix
    tag_params.fetch(:tag_prefix, '')
  end
end
