#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

STDIN_COL_WIDTH = 7

def main
  opt = OptionParser.new
  filter_params = {}
  opt.on('-l') { |v| filter_params[:lines] = v }
  opt.on('-w') { |v| filter_params[:words] = v }
  opt.on('-c') { |v| filter_params[:bytes] = v }
  opt.parse! ARGV
  filter_params = { lines: true, words: true, bytes: true } if filter_params.empty?

  contents_with_filename = ARGV.empty? ? [readlines.join] : ARGV.map { |file_name| [File.read(file_name), file_name] }
  stats = calculate_stats(contents_with_filename)
  col_width = stats.first[:file_name].nil? ? STDIN_COL_WIDTH : max_col_width(stats)
  formatted_stats = format_stats(stats:, filter_params:, col_width:)
  puts formatted_stats
end

def calculate_stats(contents_with_filename)
  stats = contents_with_filename.map { |contents, file_name| build_data(contents, file_name) }
  return stats if stats.length == 1

  add_total(stats)
end

def build_data(contents, file_name)
  lines = contents.scan(/(\n|\r)/).count
  words = contents.split(/[^\s　][\s　]+/).count
  bytes = contents.bytesize
  { lines:, words:, bytes:, file_name: }
end

def add_total(file_stats)
  total = file_stats[0].merge(*file_stats[1..]) { |_, old_value, new_value| old_value + new_value }
  total[:file_name] = :total
  file_stats << total
end

def format_stats(stats:, filter_params:, col_width:)
  stats.map do |stat|
    filtered_stat_values = stat.filter { |k| filter_params.keys[0..].include?(k) }.values
    formatted_stat_values = filtered_stat_values.map { |v| v.to_s.rjust(col_width) }.join(' ')
    [formatted_stat_values, stat[:file_name]].compact.join(' ')
  end.join("\n")
end

def max_col_width(file_stats)
  file_stats.map do |stat|
    stat.reject { |key| key == :file_name }.values.max.to_s.size
  end.max
end

main if __FILE__ == $PROGRAM_NAME
