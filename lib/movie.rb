class Movie
  attr_reader(:name, :id)

  def initialize(attributes)
    @name = attributes.fetch(:name)
    @id = attributes.fetch(:id)
  end

  def self.all
    returned_movies = DB.exec("SELECT * FROM movies;")
    movies = []
    returned_movies.each() do |movie|
      name = movie.fetch("name")
      id = movie.fetch("id").to_i()
      movies.push(Movie.new({:name => name, :id => id}))
    end
    movies
  end

  def self.find(id)
    result = DB.exec("SELECT * FROM movies WHERE id = #{id};")
    name = result.first().fetch("name")
    Movie.new({:name => name, :id => id})
  end

  def save
    result = DB.exec("INSERT INTO movies (name) VALUES ('#{@name}') RETURNING id;")
    @id = result.first().fetch("id").to_i()
  end

  def ==(another_movie)
    self.name().==(another_movie.name()).&(self.id().==(another_movie.id()))
  end

  # def update(attributes)
  #   @name = attributes.fetch(:name, @name)
  #   @id = self.id()
  #   DB.exec("UPDATE movies SET name = '#{@name}' WHERE id = #{@id};")
  # end

  # def delete
  #   DB.exec("DELETE FROM movies WHERE id = #{self.id()};")
  # end

  # def delete
  #   DB.exec("DELETE FROM actors_movies WHERE movie_id = #{self.id()};")
  #   DB.exec("DELETE FROM movies WHERE id = #{self.id()};")
  # end

  def delete
    DB.exec("DELETE FROM actors_movies WHERE actor_id = #{self.id()};")
    DB.exec("DELETE FROM actors WHERE id = #{self.id()};")
  end

  def update(attributes)
    @name = attributes.fetch(:name, @name)
    DB.exec("UPDATE movies SET name = '#{@name}' WHERE id = #{self.id()};")

    attributes.fetch(:actor_ids, []).each() do |actor_id|
      DB.exec("INSERT INTO actors_movies (actor_id, movie_id) VALUES (#{actor_id}, #{self.id()});")
    end
  end

  def actors
    movie_actors = []
    results = DB.exec("SELECT actor_id FROM actors_movies WHERE movie_id = #{self.id()};")
    results.each() do |result|
      actor_id = result.fetch("actor_id").to_i()
      actor = DB.exec("SELECT * FROM actors WHERE id = #{actor_id};")
      name = actor.first().fetch("name")
      movie_actors.push(Actor.new({:name => name, :id => actor_id}))
    end
    movie_actors
  end
end
