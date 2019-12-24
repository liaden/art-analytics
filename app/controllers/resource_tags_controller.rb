# frozen_string_literal: true

class ResourceTagsController < ApplicationController
  before_action :load_resource
  before_action :check_tag_id, only: [:update, :destroy]

  # GET /:resource/:#{resource}_id/tags
  def index
    resource.tags
    render json: { tags: resource.tags }
  end

  # POST /:resource/:#{resource}_id/tags
  def create
    new_tags = params.fetch(:tags, [])
    new_tags << params[:tag]
    new_tags = Taggable.sanitize_tag_list(new_tags)

    return render json: { error: "No (valid) tags." }, status: 400 if new_tags.empty?

    created_tags = new_tags - resource.tags.to_a
    resource.insert_tags new_tags

    resource.save!

    render json: { tags: resource.tags, created: created_tags }
  end

  # PUT /:resource/:#{resource}_id/tags/:id
  def update
    return render json: { error: "No tag passed to replace old tag" }, status: 400 unless params[:tag]

    ActiveRecord::Base.transaction do
      resource.delete_tags(params[:id])
      resource.insert_tags(params[:tag])

      resource.save!
    end

    render json: { tags: resource.tags }
  end

  # DELETE /:resource/:#{resource}_id/tags/:id
  # DELETE /:resource/:#{resource}_id/tags
  #   * deletes all tags on resource
  def destroy
    resource.delete_tags(params[:id])
    resource.save!

    render json: { tags: resource.tags, deleted: [params[:id]] }
  end

  # TODO: TESTING
  # TODO: update table to use this
  def destroy_all
    if resource.tags&.any?
      deleted_tags = resource.tags
      resource.tags = []
      resource.save!
    end

    render json: { tags: resource.tags, deleted_tags: deleted_tags || [] }
  end

  private

  def check_tag_id
    render json: { error: "Tag not found" }, status: 404 unless resource.tags.include?(params[:id])
  end

  def resource_class
    klass = Taggable.resource(params[:resource])
    return klass if Rails.env.production?

    # fall back for autoloading
    params[:resource].camelize.constantize
  end

  def resource_id_key
    "#{params[:resource].downcase}_id"
  end

  def resource
    @resource ||= resource_class.find(params[resource_id_key])
  end

  def load_resource
    resource
  rescue ActiveRecord::RecordNotFound
    logger.info "Could not find resource"
    render json: { error: 'Could not find tagged resource' }, status: 404
  end
end
