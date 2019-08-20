# frozen_string_literal: true

class TagsController < ApplicationController
  TAGGABLE_CLASSES = {
    event:       Event,
    artwork:     Artwork,
    merchandise: Merchandise,
  }.with_indifferent_access.freeze

  def index
    tags_per_resource = resources.map do |r|
      [r.name.downcase, r.tags_with_prefix(tag_prefix || '')]
    end.to_h

    render json: tags_per_resource
  end

  private

  def resources
    return TAGGABLE_CLASSES.values if specified_resources.blank?

    TAGGABLE_CLASSES.values_at(*specified_resources.map(&:downcase))
  end

  def tag_prefix
    params[:tag_prefix]
  end

  def specified_resources
    params[:resources] || []
  end
end
