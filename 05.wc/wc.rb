#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def main
  opt = OptionParser.new
  filter_params = {}
  opt.on('-l') { |v| filter_params[:lines] = v }
  opt.on('-w') { |v| filter_params[:words] = v }
  opt.on('-c') { |v| filter_params[:bytes] = v }
  opt.parse! ARGV
  filter_params = { lines: true, words: true, bytes: true } if filter_params.empty?

  if ARGV.empty?
    contents = [readlines.join]
    source_names = [:stdin]
  else
    contents = ARGV.map{ |file_name| IO.readlines(file_name, nil).pop }
    source_names = ARGV
  end
  contents_with_source_name = source_names.zip(contents).to_h
  stats = calcurate_stats(contents_with_source_name)
  col_width = stats.has_key?(:stdin) ? 7 : max_col_width(stats)
  formatted_stats = format_stats(stats:, filter_params:, col_width:)
  puts formatted_stats
end

def calcurate_stats(contents_with_source_name)
  stats = contents_with_source_name.map{ |source_name, contents| [source_name, build_data(contents)] }.to_h
  return stats if stats.length == 1

  add_total(stats)
end

def build_data(contents)
  lines = contents.scan(/(\n|\r)/).count
  words = contents.split(/[\s^　]+/).count
  bytes = contents.bytesize
  { lines:, words:, bytes: }
end

def add_total(file_stats)
  stats = file_stats.values
  total = {
    total: stats[0].merge(*stats[1..]) { |_, old_value, new_value| old_value + new_value }
  }
  file_stats.merge(total)
end

def format_stats(stats:, filter_params:, col_width:)
  stats.map do |name, stat|
    filtered_stat_values = stat.filter { |k| filter_params.keys[0..].include?(k) }.values
    formatted_stat_values = filtered_stat_values.map { |v| v.to_s.rjust(col_width) }.join(' ')
    name == :stdin ? formatted_stat_values : "#{formatted_stat_values} #{name}"
  end.join("\n")
end

def max_col_width(file_stats)
  file_stats.values.map do |stat|
    stat.values.max.to_s.size
  end.max
end

__FILE__ == $PROGRAM_NAME && main
