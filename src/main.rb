# frozen_string_literal: true

require_relative 'procs'
require_relative 'coche'

a = Coche.new('AAA', 'Audi', 'Negro')

puts a.marca

a.marca = 'BMW'

puts a.marca
