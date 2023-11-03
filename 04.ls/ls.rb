# frozen_string_literal: true

path = ARGV[0] || '.'
files = Dir.children(path).sort
number_of_files = files.size

row = 3
number_of_cols = (number_of_files % row).zero? ? number_of_files / row : number_of_files / row + 1
max_word_length = files.max_by(&:length).length
output_format = Array.new(number_of_cols) { [] }
index = 0
(1..number_of_files).each do
  index = 0 if index == number_of_cols
  output_format[index] << files.shift
  index += 1
end

output_format.each do |col|
  col.each do |word|
    print word.ljust(max_word_length + 2)
  end
  puts
end
