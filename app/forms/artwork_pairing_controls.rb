# frozen_string_literal: true

class ArtworkPairingControls
  include ActiveModel::Model
  include Virtus.model

  attribute :artwork_tag_filter_a_root,       TagFilter
  attribute :artwork_tag_filter_a_other,      TagFilter
  attribute :merchandise_tag_filter_m_root,   TagFilter
  attribute :merchandise_tag_filter_m_other,  TagFilter
  attribute :event_tag_filter,                TagFilter

  attribute :date_after,  Date
  attribute :date_before, Date

  attribute :filter_all, Boolean, default: false

  attribute :minimum_pairing_frequency, Integer, default: 1

  def initialize(params={})
    merge_on_name!(params)
    super(params)
    self.date_before ||= Date.today if self.date_after
  end

  def tag_filter_for(name)
    self.send(name) || TagFilter.new
  end

  private

  def merge_on_name!(params)
    # TODO: I should just set :event here and let query handle its table name alias
    params[:event_tag_filter] = hashify(params.delete(:event_tag_filter), :event_sold_at)

    tag_filter_params = params.keys.select { |k| k =~ /tag_filter_/ }

    tag_filter_params.each do |k|
      on = k.to_s.partition('tag_filter_').last.to_sym
      if params[k].is_a?(Hash)
        params[k][:on] ||= on
      else
        params[k] = hashify(params[k], on)
      end
    end
  end

  # TODO: delete me after updating views to use nested attrs
  # and expose more of the tag filtering options
  def hashify(tags, on)
    return unless tags

    {
      tags:               tags,
      on:                 on,
      matching_mechanism: :all,
      prepend_with:       :and,
    }
  end
end
