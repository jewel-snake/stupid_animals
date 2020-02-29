# frozen_string_literal: true

require 'ruby2d'

class World
  class << self
    attr_reader(:x_border,
      :y_boarder,
      :tics_in_day,
      :predators,
      :preys,
      :max_velocity_pred,
      :min_velocity_pred,
      :max_velocity_prey,
      :min_velocity_prey,
      :max_mass_pred,
      :min_mass_pred,
      :max_mass_prey,
      :min_mass_prey)
  end
  @x_boarder = 500
  @y_boarder = 400
  @tics_in_day = 320
  @predators = []
  @preys = []
  @max_velocity_pred = 4
  @min_velocity_pred = 2
  @max_velocity_prey = 6
  @min_velocity_prey = 1
  @max_mass_pred = 5
  @min_mass_pred = 3
  @max_mass_prey = 4
  @min_mass_prey = 1
end

class Predator
  attr_reader :mass, :speed
  def initialize(*args)
    if args.length.nil?
      @speed = World.min_velocity_pred
      @mass = World.min_mass_pred
    else
      @speed = args[0]
      @mass = args[1]
    end
    World.predators.push(self)
  end
end

class Prey
  attr_reader :mass, :speed
  def initialize(*args)
    if args.length.nil?
      @speed = World.min_velocity_prey
      @mass = World.min_mass_prey
    else
      @speed = args[0]
      @mass = args[1]
    end
    World.preys.push(self)
  end
end
