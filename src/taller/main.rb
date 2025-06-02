# frozen_string_literal: true

require_relative 'vehiculo'
require_relative 'propietario'

vehiculos = []
propietarios = []

def reg_vehiculo(vehiculos)
  puts "Matrícula:"
  matricula = gets.chomp
  puts "Marca:"
  marca = gets.chomp
  puts "Color:"
  color = gets.chomp

  v = Vehiculo.new(matricula, marca, color)
  vehiculos.push(v)
end

def reg_propietario(propietarios)
  puts "DNI:"
  dni = gets.chomp
  puts "Nombre:"
  nombre = gets.chomp
  puts "Edad:"
  edad = gets.chomp.to_i

  p = Propietario.new(dni, nombre, edad)
  propietarios.push(p)
end

def asignar_vehiculo(vehiculos, propietarios)
  puts "Elija ID de vehículo"
  vehiculos.each_with_index do |vehiculo, i|
    puts "#{i}: #{vehiculo}"
  end
  opcion = gets.chomp.to_i
  vehiculo_select = vehiculos[opcion]

  puts "Elija ID de propietario"
  propietarios.each_with_index do |propietario, i|
    puts "#{i}: #{propietario}"
  end
  opcion = gets.chomp.to_i
  propietario_select = propietarios[opcion]

  propietario_select.coches << vehiculo_select
end

def ver_coches(propietarios)
  puts "De quien"
  propietarios.each_with_index do |propietario, i|
    puts "#{i}: #{propietario}"
  end
  quien = gets.chomp.to_i

  puts propietarios[quien].coches
end

#========================================================#
#Bloque de ejecución
begin
  puts "\n1. Registrar vehículo"
  puts "2. Registrar propietario"
  puts "3. Asignar vehículo"
  puts "4. Ver coches de alguien"
  puts "-1. Salir"

  opcion = gets.chomp.to_i

  case opcion
  when 1
    reg_vehiculo(vehiculos)
  when 2
    reg_propietario(propietarios)
  when 3
    asignar_vehiculo(vehiculos, propietarios)
  when 4
    ver_coches(propietarios)
  when -1
    break
  else
    puts "Opción invalida"
  end

end while opcion != -1