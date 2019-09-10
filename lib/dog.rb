require 'pry'

class Dog
  attr_accessor :id, :name, :breed

  def initialize(params)
     params.each do |key, value|
       self.send("#{key}=", value)
     end
  end

  def self.create(params)
    Dog.new(params).save
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE dogs.id = ?
    SQL
    dog_params = DB[:conn].execute(sql,id)[0]
    self.new_from_db(dog_params)
  end

  def self.find_or_create_by(params)

    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL
    dog_params = DB[:conn].execute(sql,params[:name],params[:breed])
    #binding.pry
    if dog_params.empty?
      dog = self.create(params)
    else
      dog = self.find_by_id(dog_params[0][0])
    end
  end

  def self.create_table
    sql = <<-SQL
    DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
    sql = <<-SQL
    CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
    SQL

    DB[:conn].execute(sql)

  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end

  def self.new_from_db(params)
    params_hash = {id: params[0], name: params[1], breed: params[2]}

    Dog.new(params_hash)
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE dogs.name = ?
    SQL

    params = DB[:conn].execute(sql, name)[0]
    self.new_from_db(params)
  end

  def update
    if self.id
      sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
      SQL

      DB[:conn].execute(sql, self.name, self.breed, self.id)
    else
      self.save
    end
  end

  def save
    if self.id == nil
      sql = <<-SQL
      INSERT INTO dogs(name, breed) VALUES (?,?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)

      sql = <<-SQL
      SELECT dogs.id FROM dogs ORDER BY dogs.id DESC LIMIT 1
      SQL
      @id = DB[:conn].execute(sql)[0][0]
      self
    else
      self.update
      self
    end
  end

end
