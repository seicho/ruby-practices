# frozen_string_literal: true

def main
  path = ARGV[0] || '.'
  row = 3
  files = Dir.children(path).sort
  number_of_files = files.size
  number_of_cols = (number_of_files % row).zero? ? numbe_of_files / row : number_of_files / row + 1
  max_word_length = files.max_by(&:length).length

  finalized_filename_list = format_file_names(files, files.size, number_of_cols)
  print_result(finalized_filename_list, max_word_length)
end

def format_file_names(files, number_of_files, number_of_cols)
  output_format = Array.new(number_of_cols) { [] }
  index = 0
  (1..number_of_files).each do
    index = 0 if index == number_of_cols
    output_format[index] << files.shift
    index += 1
  end
  output_format
end

def print_result(finalized_filename_list, max_word_length)
  finalized_filename_list.each do |col|
    col.each do |word|
      print word.ljust(max_word_length + 2)
    end
    puts
  end
end

main
