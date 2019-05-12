# frozen_string_literal: true

class ReplaceModel < Mutations::Command
  required do
    model :replacee, class: ActiveRecord::Base
    model :replacer, class: ActiveRecord::Base
    array :related_tables
  end

  optional do
    boolean :destroy
    string :field_name
  end

  def validate
    if replacee.class != replacer.class
      add_error(
        :replacee, :class_mismatch,
        "replacee's class (#{replacee.class.name}) mismatches with replacers class (#{replacer.class.name})"
      )
    end

    if replacee.replaced_by_id.present?
      add_error(
        :replacee, :already_been_replaced,
        "#{replacee.name} has already been replaced by #{replacee.replaced_by.name}"
      )
    end

    if related_tables.any? { |t| t.column_names.exclude?(column_name) }
      add_error(
        :related_tables, :missing_field_name_as_column,
        "One of the related_tables #{related_tables.inspect} is missing #{column_name}"
      )
    end
  end

  def column_name
    field_name || "#{replacee.class.name.underscore}_id"
  end

  def execute
    ActiveRecord::Base.transaction do
      related_tables.each do |klass|
        klass.where(column_name => replacee.id).each do |related_item|
          related_item.send("#{column_name}=", replacer.id)
          related_item.save!
        end
      end

      if destroy
        replacee.destroy
      else
        replacee.replaced_by = replacer
        replacee.save!
      end
    end
  end
end
