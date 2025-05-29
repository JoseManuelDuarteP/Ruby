# frozen_string_literal: true

puts 'Frase:'
frase = gets.chomp

palabras = frase.downcase.split(' ')
contar = {}

palabras.each do |palabra|
  if contar.has_key?(palabra)
    contar[palabra] += 1
  else
    contar[palabra] = 1
  end
end

puts contar