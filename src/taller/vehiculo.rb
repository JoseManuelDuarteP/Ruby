# frozen_string_literal: true

class Vehiculo
  attr_accessor :matricula, :marca, :color, :propietario
  def initialize(matricula, marca, color, propietario = nil)
    @matricula = matricula
    @marca = marca
    @color = color
    @propietario = propietario
  end

  def to_s
    "Matricula: #{@matricula}, Marca: #{@marca}, Color: #{@color}"
  end
end