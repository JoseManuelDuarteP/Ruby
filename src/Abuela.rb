# frozen_string_literal: true

adios = 3

while true
  puts 'Frase: '
  frase = gets.chomp

  if frase == 'BYE'
    puts 'HUH?!  SPEAK UP, SONNY!'
    adios -= 1
    if adios == 0
      puts 'OK, BYE!'
      break
    end
  elsif frase == frase.upcase
    anyo = rand(21) + 1930
    puts 'NO, NOT SINCE ' + anyo.to_s + "!"
    adios = 3
  else
    puts 'HUH?!  SPEAK UP, SONNY!'
    adios = 3
  end
end