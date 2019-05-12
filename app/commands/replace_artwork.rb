# frozen_string_literal: true

class ReplaceArtwork < Mutations::Command
  required do
    string :replacee_name
    string :replacer_name
  end

  def execute
    replacee = Artwork.find_by(name: replacee_name)
    replacer = Artwork.find_by(name: replacer_name)

    handle_collision(replacee, replacer)

    ReplaceModel.run!(
      replacee:       replacee,
      replacer:       replacer,
      related_tables: [Merchandise]
    )
  end

  def handle_collision(replacee, replacer)
    # handle similar named merchandise for the two artworks

    replacees_merches = replacee.merchandises
    replacers_merches = replacer.merchandises.index_by(&:name)

    replacees_merches.each do |replacees_merch|
      if replacers_merch = replacers_merches[replacees_merch.name]
        ReplaceMerchandise.run!(
          replacee: replacees_merch,
          replacer: replacers_merch
        )
      end
    end
  end
end
