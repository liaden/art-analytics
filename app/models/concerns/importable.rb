module Importable
  extend ActiveSupport::Concern

  included do |base|
    base.belongs_to :import, optional: true

    #raise "Table #{base.name} is missing column import_id for Importable module" unless base.column_names.include?("import_id")
  end

  def imported?
    import_id.present?
  end
end
