require 'pry'
class Dog
  attr_reader :id
  attr_accessor :name, :breed
  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
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
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?,?)
    SQL
    response = DB[:conn].execute(sql, self.name, self.breed)
    # binding.pry
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    # Dog.new(name: self.name,breed: self.breed, id: @id)
    self
  end
  def self.create(name:, breed:)
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?,?)
    SQL
    response = DB[:conn].execute(sql, name, breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    Dog.new(name: name, breed: breed, id: @id)
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL
    response = DB[:conn].execute(sql, id)[0]
    Dog.new(name: response[1], breed: response[2], id: response[0])
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL
    response = DB[:conn].execute(sql, name, breed)[0]
    # binding.pry
    if response != nil
      Dog.new(name: response[1], breed: response[2], id: response[0])
    else
      Dog.create(name: name, breed: breed)
    end
  end
  def self.new_from_db(row)
    Dog.new(name: row[1], breed: row[2], id: row[0])
  end
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? LIMIT 1
    SQL
    response = DB[:conn].execute(sql, name)[0]
    Dog.new_from_db(response)
  end
  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    response = DB[:conn].execute(sql, self.name, self.breed, self.id)[0]
  end
end
