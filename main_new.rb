# frozen_string_literal: true

# require 'ruby2d'
require 'set'
require 'unicode_plot'
# TODO: move to real graphics statistic tool

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
    @predators.each{_1.reset}
    @preys.each{_1.reset}
    prey_inc = (@preys.length*1.75).to_i
    pred_inc = (@predators.length*1.1).to_i
    prey_inc.times{Prey.new}
    pred_inc.times{Predator.new}
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

def eat(h,p)
  h.starve += p.mass * World.k
  p.alive = false
  World.preys.delete(p)
end

class Predator
  attr_reader :mass, :speed, :x, :y, :alive
  attr_accessor :starve
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
    @alive = true
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
    unless World.preys.length.zero?
      k = World.preys.select{find_prey(self,_1) < @alert_radius}.min_by{|a| find_dist(self,a)}
      break if k.nil?
      @speed.times{step_to(k)}
    end
    @alive = false unless @starve.positive?
  end
  def step_to(p)
    break unless p.alive
    if (p.x-@x)*(p.x-@x) > (p.y-@y)*(p.y-@y)
      if p.x > @x then @x += 1 else @x -= 1 end
    else
      if p.y > @y then @y += 1 else @y -= 1 end
    end
    @starve -= World.k
    eat(self,p) if @x == p.x && @y == p.y
  end
end

class Prey
  attr_reader :mass, :speed, :x, :y
  attr_accessor :alive
  class << self
    attr_reader :alert_radius
  end
  @alert_radius = 100
  def initialize(*args)
    if args.length.zero?
      @speed = rand World.velocity_prey
      @mass = rand World.mass_prey
    else
      @speed = args[0]
      @mass = args[1]
    end
    @alive = true
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
    break if k.nil?
    @speed.times{step_from(k)}
  end
  def reset
    @y = rand World.y_boarder
    @x = rand World.x_boarder
  end
  def look_for_hunter
    World.predators.select{_1}
  end
end

def find_dist(a,b)
  (a.x-b.x)*(a.x-b.x)+(a.y-b.y)*(a.y-b.y)
end

start_preys = 50
start_predators = 10
start_preys.times{Prey.new}
start_predators.times{Predator.new}
stat = [[start_preys,start_predators]]
genofond = []
k = Thread.new{}
5.times do |t|
  break if World.preys.length.zero? || World.predators.length.zero?
  genofond = [World.preys.map{[_1.mass,_1.speed]},World.predators.map{[_1.mass,_1.speed]}]
  World.tics_in_day.times do
    break if World.preys.length.zero? 
    # TODO: new eterate scheme
    #
  end
  World.check
  k.join if k.status
  printf "passed #{t+1} days\n"
  stat.push([World.preys.length,World.predators.length])
  k = Thread.new(genofond) do |gen|
    gen[0] = gen[0].transpose
    gen[1] = gen[1].transpose
    UnicodePlot.boxplot(data: {preys: gen.first.first,preds: gen.last.first},title: 'mass').render
    UnicodePlot.boxplot(data: {preys: gen.first.last, preds: gen.last.last}, title: 'velocity').render
  end
  World.new_day
end
k.join if k.status
puts
x = 0.step(stat.length-1)
y_prey = stat.map{_1[0]}
y_pred = stat.map{_1[1]}
plot = UnicodePlot.lineplot(x,y_prey,name: "preys",width: 40, height: 10)
UnicodePlot.lineplot!(plot,x,y_pred,name:"predators")
plot.render
