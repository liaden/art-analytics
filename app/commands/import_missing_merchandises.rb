# frozen_string_literal: true

#
# TODO: REFACTOR
#  * Use bulk import from Rails 6
#  * Handle renamed merchandise better?
class ImportMissingMerchandises < Mutations::Command
  required do
    array :artworks, class: Artwork
    model :merchandise_by_artwork_name, class: Hash
    model :import
  end

  optional do
    boolean :dry_run, default: false
    boolean :allow_n_plus_one, default: false
  end

  def validate
    check_parallel_data_structure
    check_merchandise_is_already_loaded
  end

  def execute
    Merchandise.transaction do
      attr_values = []
      artworks.each do |artwork|
        existing_merch = artwork.merchandises.map(&:name)
        missing_merch  = merchandise_by_artwork_name[artwork.name] - existing_merch

        attr_values += missing_merch.map { |name| [artwork.id, name, import.id] }
      end

      Merchandise.import [:artwork_id, :name, :import_id], attr_values.uniq

      @new_merchandises = Merchandise.includes(:artwork).where(import_id: import.id).to_a

      raise ActiveRecord::Rollback if dry_run
    end

    @new_merchandises
  end

  private

  def check_parallel_data_structure
    artwork_names = artworks.map(&:name)

    if merchandise_by_artwork_name.keys.sort != artwork_names.sort
      add_error(
        :artworks_and_merchandises, :mismatched_data,
        "Mismatch between artworks and merchandise data:\n#{artwork_names}\n#{merchandise_by_artwork_name.keys}"
      )
    end
  end

  def check_merchandise_is_already_loaded
    if artworks.any? { |artwork| !artwork.association(:merchandises).loaded? }
      if prevent_n_plus_one
        add_error(:artworks, :unloaded_association, "N+1 query with merchandises")
      end
    end
  end

  def prevent_n_plus_one
    !allow_n_plus_one
  end
end
