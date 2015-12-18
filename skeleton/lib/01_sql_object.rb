require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
    @columns.first.map! {|column| column.to_sym}
  end

  def self.finalize!
    columns.each do |col|

      define_method("#{col}") do
        attributes[col]
      end

      define_method("#{col}=") do |x|
        attributes[col] = x
      end

    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= "#{self.to_s.tableize}"
  end

  def self.all
    query = DBConnection.execute(<<-SQL)
    SELECT
      #{table_name}.*
    FROM
      #{table_name}
    SQL
    parse_all(query)
  end

  def self.parse_all(results)
    parsed_results = []
    results.each do |hash|
      parsed_results << self.new(hash)
    end
    parsed_results
  end

  def self.find(id)
    query = DBConnection.execute(<<-SQL, id)
    SELECT
      *
    FROM
      #{table_name}
    WHERE
      #{table_name}.id = ?
    SQL
    parse_all(query).first
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      # byebug
      raise "unknown attribute '#{attr_name}'" unless self.class.columns.include?(attr_name.to_sym)
      attr_name = (attr_name.to_s + "=").to_sym
      send(attr_name, value)
    end

  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map {|col| send(col)}
  end

  def insert
    col_names = self.class.columns.join(", ")
    question_marks = (["?"] * (self.class.columns.length)).join(", ")
    DBConnection.execute(<<-SQL, *attribute_values)
    INSERT INTO
      #{self.class.table_name} (#{col_names})
    VALUES
      (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_line = self.class.columns.map {|attr| "#{attr} = ?"}
    set_line = set_line.join(", ")
    DBConnection.execute(<<-SQL, *attribute_values, self.id)
    UPDATE
      #{self.class.table_name}
    SET
      #{set_line}
    WHERE
      id = ?
    SQL
  end

  def save
    if id.nil?
      insert
    else
      update
    end
  end

end
