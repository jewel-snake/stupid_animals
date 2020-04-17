#// classes.rb

require 'gr/plot'
require 'numo/narray'

DFloat = Numo::DFloat

class World
  class << self
    attr_reader(:x_boarder,
      :y_boarder,
      :tics_in_day,
      :predators,
      :preys,
      :velocity_pred,
      :velocity_prey,
      :mass_pred,
      :mass_prey,
      :k)
  end

  def self.check
    @predators.reject{_1.alive}.each{@predators.delete(_1)}
  end

  def self.new_day
    @predators.each{_1.reset; _1.breed}
    @preys.each{_1.reset; _1.breed}
  end

  @x_boarder = 500
  @y_boarder = 400
  @tics_in_day = 600
  @predators = Set[]
  @preys = Set[]
  @velocity_pred = (2..4)
  @velocity_prey = (1..6)
  @mass_pred = (3..5)
  @mass_prey = (1..4)
  @k = 1.0
end

class Predator
  attr_reader :mass, :speed, :x, :y
  attr_accessor :starve, :eating
  class << self
    attr_reader :alert_radius
  end
  @alert_radius = 350
  def initialize(*args)
    if args.length.zero?
      @speed = rand World.velocity_pred
      @mass = rand World.mass_pred
    else
      @speed = args[0]
      @mass = args[1]
    end
    self.reset
    @starve = @mass.to_f
    @eating = 0
    World.predators.add(self)
  end

  def reset
    if rand() > 0.5
      @x = rand World.x_boarder
      @y = 0
    else
      @y = rand World.y_boarder
      @x = 0
    end
  end

  def find_prey
    if World.preys.length.positive?
      k = World.preys.select{find_prey(self,_1) < @alert_radius}.min_by{|a| find_dist(self,a)}
      unless k.nil?
        @speed.times do
          if @eating.positive?
            @eating -= 1
            break
          end
          step_to(k)
        end
      end
    end
    World.predators.delete(self) unless @starve.positive?
  end

  def step_to(p)
    if (p.x-@x)*(p.x-@x) > (p.y-@y)*(p.y-@y)
      if p.x > @x then @x += 1 else @x -= 1 end
    else
      if p.y > @y then @y += 1 else @y -= 1 end
    end
    @starve -= World.k
    eat(self,p) if @x == p.x && @y == p.y
  end

  def breed
    if @starve >= 2*@mass
      template = [-1,0,1]
      Predator.new(@mass+template.sample,@speed+template.sample)
      @starve -= @mass
    end
  end
end

class Prey
  attr_reader :mass, :speed, :x, :y
  class << self
    attr_reader :alert_radius
  end
  @alert_radius = 150
  def initialize(*args)
    if args.length.zero?
      @speed = rand World.velocity_prey
      @mass = rand World.mass_prey
    else
      @speed = args[0]
      @mass = args[1]
    end
    self.reset
    World.preys.add(self)
  end

  def step_from(p)
    if (p.x-@x)*(p.x-@x) > (p.y-@y)*(p.y-@y)
      if p.x > @x then @x -= 1 else @x += 1 end
    else
      if p.y > @y then @y -= 1 else @y += 1 end
    end
  end

  def run
    k = World.predators.select{find_dist(self,_1) < @alert_radius}.min_by{|a| find_dist(self,a)}
    unless k.nil? then @speed.times{step_from(k)} end
  end

  def reset
    @y = rand World.y_boarder
    @x = rand World.x_boarder
  end

  def breed
    template = [-1,0,1]
    Prey.new(@mass+template.sample,@speed+template.sample)
  end
end

class Statistics
  class << Statistics
    attr_reader :genofond, :population
    #? @genofond[day][pred/prey][mass/speed]
    @genofond = []
    @population = []
    def list_genofond
      @genofond << [[],[]]
      World.predators.each do |p|
        @genofond.last.first << [p.mass,p.speed]
      end
      World.preys.each do |p|
        @genofond.last.last << [p.mass,p.speed]
      end
    end

    def list_population
      @population << [World.predators.length,World.preys.length]
    end
    
    def show_genofond(day)
      z1 = Array.new(World.mass_pred.last){Array.new(World.velocity_pred.last){0}}
      @genofond[day][0].each do |k|
        z1[k[0]][k[1]] += 1
      end
      z2 = Array.new(World.mass_prey.last){Array.new(World.velocity_prey){0}}
      @genofond[day][1].each do |k|
        z2[k[0]][k[1]] += 1
      end
      a = DFloat.cast(z1)
      b = DFloat.cast(z2)
      Thread.new(a) do |g|
        GR.heatmap g
        sleep 10
      end
      Thread.new(b) do |g|
        GR.heatmap g
        sleep 10
      end
    end

    def show_population
      l = @population.length
      x = DFloat.linspace(0,l-1,l)
      preys = @population.map{_1[1]}
      y1 = DFloat.cast preys
      pred = @population.map{_1[0]}
      y2 = DFloat.cast pred
      Thread.new(x,y1,y2) do |x,y1,y2|
        GR.plot([x,y1],[x,y2])
        sleep 10
      end
    end
  end
end

def find_dist(a,b)
  (a.x-b.x)*(a.x-b.x)+(a.y-b.y)*(a.y-b.y)
end

def eat(h,p)
  h.starve += p.mass * World.k
  h.eating = 2
  World.preys.delete(p)
end