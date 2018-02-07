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
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs(name, breed) VALUES( ?, ? )
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(params)
    pup = Dog.new(params)
    pup.save

  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    response = DB[:conn].execute(sql, id)[0]
    self.new_from_db(response)
  end

  def self.find_or_create_by(name:, breed:)
    pup = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?;", name, breed)

      if !pup.empty?
        pup_info = {name: pup[0][1], breed: pup[0][2], id: pup[0][0]}
        pup = Dog.new(pup_info)
        pup
      else
        params = {name:name,
           breed:breed}
        self.create(params)
      end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL

    response = DB[:conn].execute(sql, name)[0]
    self.new_from_db(response)
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name= ? WHERE id = ?
    SQL

    response = DB[:conn].execute(sql, self.name, self.id)
  end

  def self.new_from_db(row)
    Dog.new(name: row[1], breed: row[2], id: row[0])
  end
end
