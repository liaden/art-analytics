class ReplaceModel < Mutations::Command

  required do
    model :replacee, class: ActiveRecord::Base
    model :replacer, class: ActiveRecord::Base
    array :related_tables
    string :field_name
  end

  def validate
    if replacee.replaced_by_id.present?
      add_error(:replacee, :already_been_replaced, "#{replacee.name} has already been replaced by #{replacee.replaced_by.name}")
    end
  end

  def execute
    ActiveRecord::Base.transaction do
      related_tables.each do |klass|
        klass.where(field_name => replacee.id).update_all(field_name  => replacer.id)
      end

      replacee.replaced_by = replacer
      replacee.save!
    end
  end
end
