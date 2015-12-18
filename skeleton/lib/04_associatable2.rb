require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

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
end

# SELECT
#   houses.*
# FROM
#   humans
# JOIN
#   houses ON humans.house_id = houses.id
# WHERE
#   humans.id = ?
