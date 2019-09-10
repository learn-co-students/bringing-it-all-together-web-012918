require 'pry'
class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(params)
    @name = params[:name]
    @breed = params[:breed]
    @id = params[:id]
  end

  def self.create_table
    sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs;
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VAlUES (?, ?);
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(params)
    dog = Dog.new(params)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
      SQL
      params = DB[:conn].execute(sql, id)[0]
      param_hash = {id: params[0], name: params[1], breed: params[2]}
      Dog.new(param_hash)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?;
    SQL
    dogs = DB[:conn].execute(sql, name, breed)[0]
    if dogs
      params = {id: dogs[0], name: dogs[1], breed: dogs[2]}
      dog = Dog.new(params)
    else
     dog = self.create(name: name, breed: breed)
    end
      dog
  end

  def self.new_from_db(row)
    params = {id: row[0], name: row[1], breed: row[2]}
    Dog.new(params)
  end

  def self.find_by_name(name)
    sql = <<-SQL
        SELECT * FROM dogs WHERE name = ?
      SQL
      params = DB[:conn].execute(sql, name)[0]
      params1 = {id: params[0], name: params[1], breed: params[2]}
      Dog.new(params1)
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ?
    SQL
    DB[:conn].execute(sql, @name, @breed)
  end

end
