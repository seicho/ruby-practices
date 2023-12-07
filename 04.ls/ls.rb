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
  filenames = get_filenames(path, params)
  formatted_items = params[:l] ? format_file_info(filenames, path) : format_filenames(filenames, path)
  width_each_columns = calculate_column_width(formatted_items, params)
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

def get_filenames(path, params)
  filenames = Dir.entries(path)
  if params[:a]
    filenames
  else
    filenames = filenames.delete_if { |f| f.start_with?('.') }
  end
  sort_filenames(filenames, params)
end

def sort_filenames(filenames, params)
  sorted_filenames = filenames.sort
  if params[:r]
    sorted_filenames.reverse
  else
    sorted_filenames
  end
end

def format_file_info(filenames, path)
  formatted_file_info = []
  filenames.each do |filename|
    f = File::Stat.new(File.realpath(filename, path))
    formatted_file_info << [
      format_file_mode(format('%06o', f.mode)),
      f.nlink,
      Etc.getpwuid(f.uid).name,
      Etc.getgrgid(f.gid).name,
      f.size,
      f.mtime.strftime('%b %e %H:%M'),
      filename
    ]
  end
  formatted_file_info
end

def format_file_mode(file_mode_int)
  m = /(?<filetype>\d{2})(?<sticky_bit>\d{1})(?<u_permission>\d{1})(?<g_permission>\d{1})(?<o_permission>\d{1})/.match(file_mode_int)
  file_type = FILE_TYPES[m[:filetype].to_sym]
  permissions = []
  (3..5).each do |i|
    permissions << PERMISSION_TYPES[m[i].to_sym]
  end
  permissions[0] = permission[0].gsub(/(..)x/, '\1s').gsub(/(..)-/, '\1S') if m[:sticky_bit].match?(/[4-7]/)
  permissions[1] = permission[1].gsub(/(..)x/, '\1s').gsub(/(..)-/, '\1S') if m[:sticky_bit].match?(/[2,3,6,7]/)
  permissions[2] = permission[2].gsub(/(..)x/, '\1t').gsub(/(..)-/, '\1T') if m[:sticky_bit].match?(/[1,3,5,7]/)
  file_type + permissions.join
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

def calculate_column_width(formatted_filenames, params)
  number_of_columns = params[:l] ? formatted_filenames[0].size : NUMBER_OF_COLUMNS
  width_each_columns = Array.new(number_of_columns, 0)
  formatted_filenames.each do |row|
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

def print_items(formatted_filenames, width_each_columns)
  formatted_filenames.each do |row|
    row.each.with_index do |item, i|
      print item.instance_of?(Integer) ? "#{item.to_s.rjust(width_each_columns[i])} " : item.ljust(width_each_columns[i] + 1)
    end
    puts
  end
end

__FILE__ == $PROGRAM_NAME && main
