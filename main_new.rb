# frozen_string_literal: true

#// main.rb

# require 'ruby2d'
require 'set'

load 'src/classes.rb'

start_preys = 50
start_predators = 10
start_preys.times{Prey.new}
start_predators.times{Predator.new}
max_days = 2
max_days.times do |t|
  break if World.preys.length.zero? || World.predators.length.zero?
  World.tics_in_day.times do
    break if World.preys.length.zero? || World.predators.zero?
    World.predators.each{ |p| p.find_prey}
    World.preys.each{|p| p.run}
  end
  printf "passed #{t+1} days\n"
  World.new_day
  Statistics.list_genofond
  Statistics.list_population
end
Statistics.show_population
