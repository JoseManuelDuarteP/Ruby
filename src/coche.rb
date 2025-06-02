# frozen_string_literal: true

class Coche
  attr_accessor :matricula, :marca, :color
  def initialize(matricula, marca, color)
    @matricula = matricula
    @marca = marca
    @color = color
  end
end