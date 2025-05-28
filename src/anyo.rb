# frozen_string_literal: true

puts 'Primer año:'
primer_anyo = gets.chomp.to_i

puts 'Segundo año:'
segundo_anyo = gets.chomp.to_i

while primer_anyo <= segundo_anyo
  if primer_anyo % 400 == 0
    puts primer_anyo.to_s
  elsif primer_anyo % 100 == 0

  elsif primer_anyo % 4 == 0
    puts primer_anyo.to_s
  end
  primer_anyo += 1
end