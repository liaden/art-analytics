# frozen_string_literal: true

class PairedArtworksController < ApplicationController
  def new
    @controls = ArtworkPairingControls.new(minimum_pairing_frequency: 3)
    send_data_to_gon(@controls)
  end

  # fake save
  def create
    tag_cleaner_process
    @controls = ArtworkPairingControls.new(pairing_params)
    send_data_to_gon(@controls)
    render :new
  end

  private

  def tag_cleaner_process
    tagify_cleaner.process!(:artwork_pairing_controls, :artwork_tag_filter_a_root)
    tagify_cleaner.process!(:artwork_pairing_controls, :artwork_tag_filter_a_other)
    tagify_cleaner.process!(:artwork_pairing_controls, :event_tag_filter)
  end

  def send_data_to_gon(controls)
    data = ArtworkPairings.new(controls).run

    gon.push(data: sunburst_serialize(data))
  end

  def sunburst_serialize(data)
    # values is what nvd3 needs for the sunburst so autocreate if missing
    result = Hash.new { |h,k| h[k] = { name: k, children: [] } }

    data.each do |row|
      result[row['root_name']][:children] << { name: row['associated_artwork_name'], value: row['paired_frequency'] }
    end

    [{ name: 'everything', children: result.values }]
  end

  def pairing_params
    params
      .require(:artwork_pairing_controls)
      .permit(:date_after,
              :date_before,
              :minimum_pairing_frequency,
              merchandise_tag_filter_m_root: [],
              merchandise_tag_filter_m_other: [],
              artwork_tag_filter_a_root: [],
              artwork_tag_filter_a_other: [],
              event_tag_filter: [],
             )
  end
end
