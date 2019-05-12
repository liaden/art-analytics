# frozen_string_literal: true

module Importable
  extend ActiveSupport::Concern

  included do |base|
    base.belongs_to :import, optional: true
  end

  def imported?
    import_id.present?
  end
end
