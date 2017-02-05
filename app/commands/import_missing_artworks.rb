class ImportMissingArtworks < Mutations::Command
  required do
    array :names, class: String
    model :import
  end

  optional do
    boolean :dry_run, default: false
  end

  def validate
  end

  def execute
    Artwork.transaction do
      existing_artworks = Artwork.where(name: names).pluck(:name)
      missing_artworks = names - existing_artworks

      attr_values = missing_artworks.map { |name| [name, import.id] }
      Artwork.import [:name, :import_id], attr_values

      @new_artworks = Artwork.includes(:merchandises).where(import_id: import.id).to_a
      @new_artworks.each do |artwork|
        Merchandise.create_unknown_for(artwork)
      end

      raise ActiveRecord::Rollback if dry_run
    end

    @new_artworks
  end
end
