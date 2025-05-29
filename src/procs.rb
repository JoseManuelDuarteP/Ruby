# frozen_string_literal: true

def decir_estado = Proc.new do |nota|
  if nota < 5
    'Va ha ser que no'
  else
    'Has aprobado!'
  end
end

def examen
  puts 'Nota:'
  nota = gets.chomp.to_i

  decir_estado.call(nota)
end

puts examen