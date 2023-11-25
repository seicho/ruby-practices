# frozen_string_literal: true

def main
  path = ARGV[0] || '.'
  row = 3
  files, max_word_length = analyze_directory(path)
  formatted_filenames = format_filename_list(files, row)
  print_result(formatted_filenames, max_word_length)
end

def analyze_directory(path)
  files = Dir.children(path).sort
  max_word_length = files.max_by(&:length).length
  [files, max_word_length]
end

def format_filename_list(files, row)
  number_of_files = files.size
  number_of_cols = (number_of_files % row).zero? ? number_of_files / row : number_of_files / row + 1
  formatted_filenames = Array.new(number_of_cols) { [] }
  allocated_files = 0
  (1..number_of_files).each do
    allocated_files = 0 if allocated_files == number_of_cols
    formatted_filenames[allocated_files] << files.shift
    allocated_files += 1
  end
  formatted_filenames
end

def print_result(formatted_filenames, max_word_length)
  formatted_filenames.each do |col|
    col.each do |word|
      print word.ljust(max_word_length + 2)
    end
    puts
  end
end

main
