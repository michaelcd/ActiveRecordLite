#ActiveRecord Lite

An ORM built to duplicate the methods of Ruby on Rails' ActiveRecord. Abstracts complex SQL queries to Ruby objects via modules and inheritance.


## Methods
* `SQLObject::all` returns all rows within the object's corresponding table.
* `SQLObject::find(id)` returns an SQLObject corresponding with the database record for the argument `id`.
* `SQLObject::where(params)` takes a hash as an argument and executes an SQL query based on the keys/values in the hash, then returns an array of SQLObjects representing the database records.
* `SQLObject::belongs_to(name, options)` creates a `BelongsToOptions` instance to create the association between two database tables, then creates a `name` method to access the associated object.
* `SQLObject::has_many(name, options)` creates a `HasManyOptions` instance to create the association between two database tables, then creates a `name` method to access the associated object.
* `SQLObject::has_many_through`
* `SQLObject#insert`
* `SQLObject#update`
* `SQLObject#save`
* `SQLObject#destroy` removes the object's row/data from the corresponding database table.
* `SQLObject#delete` is an alias method for `SQLObject#destroy`.


<!-- ##ActiveRecordLite::Base
* ::validates
* ::has_one_through
* #errors
* #valid? -->
