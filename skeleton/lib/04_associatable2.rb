require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)

    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      source_table_name = source_options.model_class.table_name #ok
      thru_table_name = through_options.model_class.table_name #ok
      source_fgn_key = source_options.foreign_key
      join_line = "#{source_table_name} ON #{thru_table_name}.#{source_fgn_key} = #{source_table_name}.id"
      searchid = self.send(through_options.foreign_key)
      result = DBConnection.execute(<<-SQL, searchid)
      SELECT
        #{source_table_name}.*
      FROM
        #{thru_table_name}
      JOIN
        #{join_line}
      WHERE
        #{thru_table_name}.id = ?
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
