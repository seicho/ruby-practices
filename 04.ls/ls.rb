# frozen_string_literal: true
require 'optparse'

def main
  opt = OptionParser.new
  params = {}
  opt.on('-a') {|v| params[:a] = v}
  opt.parse!(ARGV)
  path = ARGV[0] || '.'
  row = 3
  filenames =  generate_filenames(path, params).sort
  formatted_filenames = format_filenames(filenames, row)
  margin_each_rows = calculate_margin(formatted_filenames, row)
  print_result(formatted_filenames, margin_each_rows)
end

def generate_filenames(path, params)
  if params[:a]
    Dir.entries(path)
  else
    Dir.entries(path).delete_if {|f| f.start_with?('.') } 
  end
end

def format_filenames(filenames, row)
  number_of_filenames = filenames.size
  number_of_cols = (number_of_filenames % row).zero? ? number_of_filenames / row : number_of_filenames / row + 1
  formatted_filenames = Array.new(number_of_cols) { [] }
  allocated_filenames = 0
  (0..number_of_filenames - 1).each do |i|
    allocated_filenames = 0 if allocated_filenames == number_of_cols
    formatted_filenames[allocated_filenames] << filenames[i]
    allocated_filenames += 1
  end
  formatted_filenames
end

def calculate_margin(formatted_filenames, row)
  margin_each_rows = Array.new(row, 0)
  formatted_filenames.each do |col|
    (0..row - 2).each do |i|
      margin_each_rows[i] = col[i].length if col[i] && margin_each_rows[i] < col[i].length
    end
  end
  margin_each_rows
end

def print_result(formatted_filenames, margin_each_rows)
  formatted_filenames.each do |col|
    col.each.with_index do |word, i|
      print word.ljust(margin_each_rows[i] + 2)
    end
    puts
  end
end

if __FILE__ == $0
  main
end
