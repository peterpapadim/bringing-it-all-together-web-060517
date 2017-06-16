require 'pry'

class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name_breed, id=nil)
    @name = name_breed[:name]
    @breed = name_breed[:breed]
    @id = id
  end

  def self.create_table
    query = ("CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )")
    DB[:conn].execute(query)
  end

  def self.drop_table
    query = ("DROP TABLE dogs")
    DB[:conn].execute(query)
  end

  def save
    query = ("INSERT INTO dogs (name, breed)
    VALUES (?, ?)")
    DB[:conn].execute(query, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(name_breed)
    dog = self.new(name_breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    query = ("SELECT * FROM dogs WHERE id = ?")
    result = DB[:conn].execute(query, id).first
    dog = self.new({name: result[1], breed: result[2]}, result[0])
  end

  def self.find_or_create_by(name_breed)
    query = ("SELECT * FROM dogs WHERE name = ? AND breed = ?")
    result = DB[:conn].execute(query, name_breed[:name], name_breed[:breed])
    if !result.empty?
      dog_result = result.first
      dog = self.new({name: dog_result[1], breed: dog_result[2]}, dog_result[0])
    else
      dog = self.create(name_breed)
    end
      dog
  end

  def self.new_from_db(row)
    dog = self.new({name: row[1], breed: row[2]}, row[0])
  end

  def self.find_by_name(name)
    query = ("SELECT * FROM dogs WHERE name = ?")
    result = DB[:conn].execute(query, name).first
    self.new_from_db(result)
  end

  def update
    query = ("UPDATE dogs SET name = ?, breed = ?, id = ?")
    DB[:conn].execute(query, self.name, self.breed, self.id)
  end

end
