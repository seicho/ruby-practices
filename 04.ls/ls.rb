#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

NUMBER_OF_COLUMNS = 3
FILE_TYPES = {
  '01': 'p',
  '02': 'c',
  '04': 'd',
  '06': 'b',
  '10': '-',
  '12': 'l',
  '14': 's'
}.freeze
PERMISSION_TYPES = {
  '0': '---',
  '1': '--x',
  '2': '-w-',
  '3': '-wx',
  '4': 'r--',
  '5': 'r-x',
  '6': 'rw-',
  '7': 'rwx'
}.freeze

def main
  params = parse_option
  path = ARGV[0] || '.'
  filenames = read_filenames(path, params)
  number_of_columns = NUMBER_OF_COLUMNS
  if params[:l]
    formatted_items, total_blocks = format_file_info(filenames, path)
    puts "total #{total_blocks}" if params[:l]
    number_of_columns = formatted_items[0].size
  else
    formatted_items = format_filenames(filenames)
  end

  width_each_columns = calculate_column_width(formatted_items, number_of_columns)
  print_items(formatted_items, width_each_columns)
end

def parse_option
  opt = OptionParser.new
  params = {}
  opt.on('-a') { |v| params[:a] = v }
  opt.on('-r') { |v| params[:r] = v }
  opt.on('-l') { |v| params[:l] = v }
  opt.parse!(ARGV)
  params
end

def read_filenames(path, params)
  filenames = Dir.entries(path)
  !params[:a] && (filenames = filenames.delete_if { |f| f.start_with?('.') })
  sort_filenames(filenames, params)
end

def sort_filenames(filenames, params)
  sorted_filenames = filenames.sort
  params[:r] && (sorted_filenames = sorted_filenames.reverse)
  sorted_filenames
end

def format_file_info(filenames, path)
  formatted_file_info = []
  total_blocks = 0
  Dir.chdir(path)
  filenames.each do |filename|
    f = File.lstat(filename)
    formatted_file_info << [
      format_file_mode(format('%06o', f.mode)),
      f.nlink,
      Etc.getpwuid(f.uid).name,
      Etc.getgrgid(f.gid).name,
      f.size,
      f.mtime.strftime('%b %e %H:%M'),
      filename
    ]
    total_blocks += f.blocks / 2
  end
  [formatted_file_info, total_blocks]
end

def format_file_mode(file_mode_int)
  m = /(?<filetype>\d{2})(?<sticky_bit>\d{1})(?<u_permission>\d{1})(?<g_permission>\d{1})(?<o_permission>\d{1})/.match(file_mode_int)
  u_permission = PERMISSION_TYPES[m[:u_permission].to_sym]
  g_permission = PERMISSION_TYPES[m[:g_permission].to_sym]
  o_permission = PERMISSION_TYPES[m[:o_permission].to_sym]
  m[:sticky_bit].match?(/[5-7]/)     && u_permission = u_permission.gsub(/(..)x/, '\1s').gsub(/(..)-/, '\1S')
  m[:sticky_bit].match?(/[2,3,6,7]/) && g_permission = g_permission.gsub(/(..)x/, '\1s').gsub(/(..)-/, '\1S')
  m[:sticky_bit].match?(/[1,3,5,7]/) && o_permission = o_permission.gsub(/(..)x/, '\1t').gsub(/(..)-/, '\1T')
  file_type = FILE_TYPES[m[:filetype].to_sym]
  file_type + u_permission + g_permission + o_permission
end

def format_filenames(filenames)
  number_of_filenames = filenames.size
  number_of_cols = (number_of_filenames % NUMBER_OF_COLUMNS).zero? ? number_of_filenames / NUMBER_OF_COLUMNS : number_of_filenames / NUMBER_OF_COLUMNS + 1
  formatted_filenames = Array.new(number_of_cols) { [] }
  allocated_filenames = 0
  (0..number_of_filenames - 1).each do |i|
    allocated_filenames = 0 if allocated_filenames == number_of_cols
    formatted_filenames[allocated_filenames] << filenames[i]
    allocated_filenames += 1
  end
  formatted_filenames
end

def print_items(formatted_items, width_each_columns)
  formatted_items.each do |row|
    row.each.with_index do |item, i|
      print item.instance_of?(Integer) ? "#{item.to_s.rjust(width_each_columns[i])} " : item.ljust(width_each_columns[i] + 1)
    end
    puts
  end
end

def calculate_column_width(formatted_items, number_of_columns)
  width_each_columns = Array.new(number_of_columns, 0)
  formatted_items.each do |row|
    (0..number_of_columns - 2).each do |i|
      item = row[i].to_s
      width_each_columns[i] = if !row[i].nil? && (width_each_columns[i] < item.length)
                                item.length
                              else
                                width_each_columns[i]
                              end
    end
  end
  width_each_columns
end

__FILE__ == $PROGRAM_NAME && main
