# frozen_string_literal: true

class Propietario
  attr_accessor :dni, :nombre, :edad, :coches
  def initialize(dni, nombre, edad)
    @dni = dni
    @nombre = nombre
    @edad = edad
    @coches = []
  end

  def to_s
    "DNI: #{@dni}, Nombre: #{@nombre}, Edad: #{@edad}"
  end
end
