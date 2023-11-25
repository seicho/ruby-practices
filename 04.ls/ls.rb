# frozen_string_literal: true

def main
  path = ARGV[0] || '.'
  row = 3
  files = Dir.children(path).sort
  max_word_length = files.max_by(&:length).length
  formatted_filename_list = format_filename_list(files, row)
  print_result(formatted_filename_list, max_word_length)
end

def format_filename_list(files, row)
  number_of_files = files.size
  number_of_cols = (number_of_files % row).zero? ? number_of_files / row : number_of_files / row + 1
  formatted_filename_list = Array.new(number_of_cols) { [] }
  allocated_files = 0
  (1..number_of_files).each do
    allocated_files = 0 if allocated_files == number_of_cols
    formatted_filename_list[allocated_files] << files.shift
    allocated_files += 1
  end
  formatted_filename_list
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
