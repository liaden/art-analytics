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

  attribute :minimum_pairing_frequency, Integer, default: 1

  def initialize(params = {})
    merge_on_name!(params)
    super(params)
    self.date_before ||= Date.today if self.date_after
  end

  def tag_filter_for(name)
    self.send(name) || TagFilter.new
  end

  private

  def merge_on_name!(params)
    tag_filter_params = params.keys.select { |k| k =~ /tag_filter_/ }
    tag_filter_params.each do |k|
      params[k][:on] ||=  k.to_s.partition('tag_filter_').last.to_sym
    end
  end
end
