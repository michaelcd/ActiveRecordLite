#ActiveRecord Lite

An ORM built to duplicate the methods of Ruby on Rails' ActiveRecord. Abstracts complex SQL queries to Ruby objects via modules and inheritance.

## Methods
* `SQLObject::all` returns all rows within the object's corresponding table.
* `SQLObject::find(id)` returns an SQLObject corresponding with the database record for the argument `id`.
* `SQLObject::where(params)` takes a hash as an argument and executes an SQL query based on the keys/values in the hash, then returns an array of SQLObjects representing the database records.
* `SQLObject::belongs_to(name, options)` creates a `BelongsToOptions` instance to create the association between two database tables, then creates a `name` method to access the associated object.
* `SQLObject::has_many(name, options)` creates a `HasManyOptions` instance to create the association between two database tables, then creates a `name` method to access the associated objects.
* `SQLObject::has_many_through(name, through_name, source_name)` defines a relationship between two SQLObjects through two `#belongs_to` relationships. Defines a method, `name`, that returns a SQLObject whose `#model_name` corresponds to the `source_name`
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
