# frozen_string_literal: true

frase_entera = []

while true
  puts 'Introduzca frase:'
  frase = gets.chomp
  if frase == ''
    break
  end
  frase_entera.push(frase)
end

frase_entera.each do |frase|
  print frase + " "
end