# frozen_string_literal: true

def raiz_cuadrada(numero)
  Math::sqrt(numero)
end

def positivo?(numero)
  if numero > 0
    true
  elsif numero < 0
    false
  else
    'Cero'
  end
end

puts positivo?(0)

puts raiz_cuadrada(4)