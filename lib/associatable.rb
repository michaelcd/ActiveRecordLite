require_relative 'searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    "#{class_name.downcase}s"
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] || "#{name}_id".to_sym
    @class_name = options[:class_name] || "#{name.capitalize}"
    @primary_key = options[:primary_key] || :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] || "#{self_class_name.downcase}_id".to_sym
    @class_name = options[:class_name] || "#{name.to_s.capitalize.singularize}"
    @primary_key = options[:primary_key] || :id
  end
end

module Associatable
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options

    define_method(name) do
      foreign_key = self.send(options.foreign_key)
      primary_key = options.primary_key
      options.model_class.where(primary_key => foreign_key).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)

    define_method(name) do
      foreign_key = options.foreign_key
      options.model_class.where(foreign_key => self.id)
    end
  end

  def has_one_through(name, through_name, source_name)
    define_method(name) do

      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      src_table = source_options.model_class.table_name
      thru_table = through_options.model_class.table_name
      src_fgn_key = source_options.foreign_key
      join_line = "#{src_table} ON #{thru_table}.#{src_fgn_key} = #{src_table}.id"
      searchid = self.send(through_options.foreign_key)

      result = DBConnection.execute(<<-SQL, searchid)
      SELECT
        #{src_table}.*
      FROM
        #{thru_table}
      JOIN
        #{join_line}
      WHERE
        #{thru_table}.id = ?
      SQL
      source_options.model_class.parse_all(result).first
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
end

class SQLObject
  extend Associatable
end
