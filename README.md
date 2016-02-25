#ActiveRecordLite

An ORM inspired by Ruby on Rails' ActiveRecord. Abstracts complex SQL queries to Ruby objects via modules and inheritance.

## How to use in your project

### Setting up a database

ActiveRecordLite was built using [SQLite3]. SQLite must be installed as well as the `sqlite3` gem.

This repo has a demo.sql file containing SQL commands to setup tables and insert data, and will save the database to demo.db. `DBConnection::reset` will delete the demo.db and re-run the demo.sql file.

To use in your own project, change the `DEMO_SQL_FILE` and `DEMO_DB_FILE` constants in db_connection.rb to point to your own files.

[SQLite3]: https://www.sqlite.org

### Using the SQLObject class

Require `active_record_lite.rb` in your project, and when creating an object set it to inherit from `SQLObject`.

```ruby
class List < SQLObject
  belongs_to :board, foreign_key: :board_id
  has_many :cards, foreign_key: :list_id
  finalize!
end
```

More examples can be seen in the demo.rb file.

## Methods
* `SQLObject::all` returns all rows within the object's corresponding table.
* `SQLObject::find(id)` returns an SQLObject corresponding with the database record for the argument `id`.
* `SQLObject::where(params)` takes a hash as an argument and executes an SQL query based on the keys/values in the hash, then returns an array of SQLObjects representing the database records.
* `SQLObject::belongs_to(name, options)` creates a `BelongsToOptions` instance to create the association between two database tables, then creates a `name` method to access the associated object.
* `SQLObject::has_many(name, options)` creates a `HasManyOptions` instance to create the association between two database tables, then creates a `name` method to access the associated objects.
* `SQLObject::has_many_through(name, through_name, source_name)` defines a relationship between two SQLObjects through two `#belongs_to` relationships. Defines a method, `name`, that returns a SQLObject whose `#model_name` corresponds to the `source_name`.
* `SQLObject#insert` creates new row in the database with the SQLObject's attributes and assigns an id.
* `SQLObject#update` updates corresponding row in database table with attributes from object in Ruby.
* `SQLObject#save` inserts or updates SQLObject based on id.nil?
* `SQLObject#destroy` removes the object's row/data from the corresponding database table.
* `SQLObject#delete` is an alias method for `SQLObject#destroy`.

## Future methods
* ::validates
* ::has_one_through
* #errors
* #valid?
