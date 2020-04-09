# frozen_string_literal: true

# require 'ruby2d'
require 'set'
require 'unicode_plot'
# TODO: move to real graphics statistic tool

load 'src/classes.rb'

start_preys = 50
start_predators = 10
start_preys.times{Prey.new}
start_predators.times{Predator.new}
max_days = 5
stat = [[start_preys,start_predators]]
genofond = []
k = Thread.new{}
max_days.times do |t|
  break if World.preys.length.zero? || World.predators.length.zero?
  genofond = [World.preys.map{[_1.mass,_1.speed]},World.predators.map{[_1.mass,_1.speed]}]
  World.tics_in_day.times do
    break if World.preys.length.zero? 
    # TODO: new eterate scheme
    load 'srd/eng.rb'
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
