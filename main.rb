# frozen_string_literal: true

#require 'ruby2d'
require 'set'
require 'unicode_plot'

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
      :mass_prey)
  end
  def self.check
    @predators.select{_1.starve > 0}.each{@predators.delete(_1)}
  end
  def self.new_day
    @predators.each do |p|
      p.reset
      p.starve = p.mass
    end
    @preys.each do |p|
      p.reset
    end
    prey_inc = (@preys.length*1.75).to_i
    pred_inc = (@predators.length*1.1).to_i
    prey_inc.times{Prey.new}
    pred_inc.times{Predator.new}
  end
  @x_boarder = 500
  @y_boarder = 400
  @tics_in_day = 1000
  @predators = Set[]
  @preys = Set[]
  @velocity_pred = (2..4)
  @velocity_prey = (1..6)
  @mass_pred = (3..5)
  @mass_prey = (1..4)
end

def eat(h,p)
  h.starve -= p.mass
  World.preys.delete(p)
end

class Predator
  attr_reader :mass, :speed, :x, :y
  attr_accessor :starve
  def initialize(*args)
    if args.length.zero?
      @speed = World.velocity_pred.first
      @mass = World.mass_pred.first
    else
      @speed = args[0]
      @mass = args[1]
    end
    @x = rand(World.x_boarder)
    @y = rand(World.y_boarder)
    @starve = @mass
    World.predators.add(self)
  end
  def reset
    @x = rand World.x_boarder
    @y = rand World.y_boarder
  end
  def find_prey
    unless World.preys.length.zero?
      k = World.preys.min_by{|a| (a.x-@x)*(a.x-@x)+(a.y-@y)*(a.y-@y)}
      @speed.times{step_to(k)}
    end
  end
  def step_to(p)
    if (p.x-@x)*(p.x-@x) > (p.y-@y)*(p.y-@y)
      if p.x > @x
        @x += 1
      else
        @x -= 1
      end
    else
      if p.y > @y
        @y += 1
      else
        @y -= 1
      end
    end
    eat(self,p) if @x == p.x && @y == p.y
  end
end

class Prey
  attr_reader :mass, :speed, :x, :y
  def initialize(*args)
    if args.length.zero?
      @speed = World.velocity_prey.first
      @mass = World.mass_prey.first
    else
      @speed = args[0]
      @mass = args[1]
    end
    @x = rand(World.x_boarder)
    @y = rand(World.y_boarder)
    World.preys.add(self)
  end
  def step_from(p)
    if (p.x-@x)*(p.x-@x) > (p.y-@y)*(p.y-@y)
      if p.x > @x
        @x -= 1
      else
        @x += 1
      end
    else
      if p.y > @y
        @y -= 1
      else
        @y += 1
      end
    end
  end
  def run
    k = World.predators.min_by{|a| (a.x-@x)*(a.x-@x)+(a.y-@y)*(a.y-@y)}
    @speed.times{step_from(k)}
  end
  def reset
    @x = rand World.x_boarder
    @y = rand World.y_boarder
  end
end
def count(a,b)
  ans = [0]*b
  a.each{ans[_1]+=1}
  ans
end

start_preys = 150
start_predators = 14
start_preys.times{Prey.new}
start_predators.times{Predator.new}
stat = [[start_preys,start_predators]]
genofond = []
31.times do |t|
  break if World.preys.length.zero? || World.predators.length.zero?
  genofond.push [World.preys.map{[_1.mass,_1.velocity]},World.predators.map{[_1.mass,_1.velocity]}]
  World.tics_in_day.times{
    World.preys.each{_1.run}
    World.predators.each{_1.find_prey if _1.starve > 0}
    break if World.preys.length.zero? 
  }
  World.check
  printf "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\bended in #{t+1} days"
  stat.push([World.preys.length,World.predators.length])
  World.new_day
end
puts
x = 0.step(stat.length-1)
y_prey = stat.map{_1[0]}
y_pred = stat.map{_1[1]}
plot = UnicodePlot.lineplot(x,y_prey,name: "preys",width: 40, height: 10)
UnicodePlot.lineplot!(plot,x,y_pred,name:"predators")
plot.render
