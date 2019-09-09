require "pry"

class Dog
  attr_accessor :name, :breed, :id
  attr_reader

  def initialize(args)
    @id = nil
    args.each{ |k,v|
      self.send("#{k}=", v)
    }
  end

  def self.create_table
    sql=<<-SQL
      CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql=<<-SQL
      DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end

  def self.create(attr)
    dog = Dog.new(attr)
    dog.save
  end

  def self.find_or_create_by(attr)
    sql=<<-SQL
    SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL
    results = DB[:conn].execute(sql, attr[:name], attr[:breed])
    # binding.pry
    if !results.empty?
      find_by_id(results[0][0])
    else
      dog = Dog.create({name: attr[:name], breed: attr[:breed]})
    end
  end

  def self.new_from_db(array)
    hash = {id: array[0], name: array[1], breed: array[2]} #refactor this later
    Dog.new(hash)
  end

  def self.find_by_id(id)
    sql=<<-SQL
    SELECT * FROM dogs WHERE id = ?
    SQL
    array = DB[:conn].execute(sql, id)[0]
    hash = {id: array[0], name: array[1], breed: array[2]}
    Dog.new(hash)
    # binding.pry
  end

  def self.find_by_name(name)
    sql=<<-SQL
    SELECT * FROM dogs WHERE name = ?
    SQL
    array = DB[:conn].execute(sql, name)[0]
    hash = {id: array[0], name: array[1], breed: array[2]}
    Dog.new(hash)

  end

  def update
    sql=<<-SQL
    UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    sql=<<-SQL
    INSERT INTO dogs (name, breed) VALUES (?,?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end
end

# sql=<<-SQL
#
# SQL
# DB[:conn].execute(sql)
