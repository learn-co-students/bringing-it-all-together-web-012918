class Dog
  attr_accessor :id, :name, :breed

  def initialize(dog)
    @id = dog[:id]
    @name = dog[:name]
    @breed = dog[:breed]
  end

  def self.create_table
    DB[:conn].execute('DROP TABLE IF EXISTS dogs')
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
      SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute('DROP TABLE IF EXISTS dogs')
  end

  def save
    if self.id
      saved = self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def self.create(dog)
    created_dog = self.new(dog)
    created_dog.save
  end

  def self.find_by_id(id)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0]
    dog_attr_hash = {id: row[0], name: row[1], breed: row[2]}
    self.new(dog_attr_hash)
  end

  def self.find_or_create_by(dog)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", dog[:name], dog[:breed])[0]
    if row
      self.new_from_db(row)
    else
      self.create(dog)
    end
  end

  def self.new_from_db(row)
    dog_attr_hash = {id: row[0], name: row[1], breed: row[2]}
    self.new(dog_attr_hash)
  end

  def self.find_by_name(dog_name)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", dog_name)[0]
    self.new_from_db(row)
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
      SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
