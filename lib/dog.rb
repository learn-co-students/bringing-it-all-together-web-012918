require 'pry'

class Dog

  attr_accessor :name, :breed, :id

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
    DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id == nil
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT id FROM dogs WHERE name = ? AND breed = ?", self.name, self.breed)[0][0]
      self
    else
      self.update
    end
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
  end

  def self.create(params)
    dog = Dog.new(params)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL
    dog = DB[:conn].execute(sql, id)[0]
    params_hash = {id: dog[0], name: dog[1], breed: dog[2]}
    Dog.new(params_hash)
  end

  def self.find_or_create_by(params)
    if self.find_by_name_and_breed(params) == nil
      self.create(params)
    else
      dog = self.find_by_name_and_breed(params)
      params_hash = {name: dog[1], breed: dog[2]}
      new_dog = self.create(params_hash)
    end
  end

  def self.find_by_name_and_breed(params)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL
    DB[:conn].execute(sql, params[:name], params[:breed])[0]
  end

  def self.new_from_db(row)
    params_hash = {id: row[0], name: row[1], breed: row[2]}
    Dog.new(params_hash)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL
    dog = DB[:conn].execute(sql, name)[0]
    params_hash = {id: dog[0], name: dog[1], breed: dog[2]}
    Dog.new(params_hash)
  end
end

# binding.pry
# 'hi'
