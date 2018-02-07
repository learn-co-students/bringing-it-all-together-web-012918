require 'pry'

class Dog
  attr_accessor :id, :name, :breed

  def initialize(hash)
    hash.each do |key, value|
      send("#{key}=", value)
    end
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def self.new_from_db(arr)
    hash = {}
    hash["id"] = arr[0]
    hash["name"] = arr[1]
    hash["breed"] = arr[2]
    Dog.new(hash)
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?
    SQL
    result = DB[:conn].execute(sql, name)[0]
    self.new_from_db(result)
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
      SQL
      result = DB[:conn].execute(sql, self.name, self.breed, self.id)
      # binding.pry
      #

      #not returning correct id. returning num, not num in arr.
  end

  def save
    if self.id
      self.update

    else
      sql = <<-SQL
        INSERT INTO dogs
        (name, breed)
        VALUES (?, ?)
      SQL
          item = DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      # binding.pry
      ####need to return instance
      ####relies on update method ^^^^^
      self
      # binding.pry
    end
  end

  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL
    array = DB[:conn].execute(sql, id)
    Dog.new_from_db(array[0])
  end

  def self.find_or_create_by(hash)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL
    dog = DB[:conn].execute(sql, hash[:name], hash[:breed])
    if !dog.empty?
      dog_data = dog[0]

      # binding.pry

      dog = Dog.new_from_db(dog_data)
    else
      dog = self.create(hash)
      # binding.pry

    end
    dog
  end

end
