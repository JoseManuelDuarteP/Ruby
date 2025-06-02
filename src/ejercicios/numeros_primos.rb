# frozen_string_literal: true

puts 'Número inferior'
num1 = gets.chomp.to_i
puts 'Número superior'
num2 = gets.chomp.to_i

primos = []

while num1 <= num2

  if num1 < 2
    num1 += 1
    next
  end

  es_primo = true
  iter = 2

  while iter < num1
    if num1 % iter == 0
      es_primo = false
      break
    end
    iter += 1
  end

  if es_primo
    primos.push(num1)
  end

  num1 += 1
end

puts primos