#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def main
  opt = OptionParser.new
  filter_params = {}
  opt.on('-l') { |v| filter_params[:lines] = v }
  opt.on('-w') { |v| filter_params[:chars] = v }
  opt.on('-c') { |v| filter_params[:bytes] = v }
  opt.parse! ARGV
  filter_params = { lines: true, chars: true, bytes: true } if filter_params.empty?
  formatted_stats = if ARGV.size == 1
                      format_file_stats(file_stats:, filter_params:)
                    elsif ARGV.size >= 2
                      file_stats_with_total = calcurate_total file_stats
                      format_file_stats(file_stats: file_stats_with_total, filter_params:)
                    else
                      input = readlines.join
                      stat = build_data(input)
                      format(stat:, filter_params:)
                    end
  puts formatted_stats
end

def file_stats
  ARGV.map do |file_name|
    contents = IO.readlines(file_name).join
    stats = build_data(contents)
    [file_name, { lines: stats[:lines], chars: stats[:chars], bytes: stats[:bytes] }]
  end.to_h
end

def build_data(contents)
  lines = contents.scan(/(\n|\r)/).count
  chars = contents.split(/\s+/).count
  bytes = contents.size
  { lines:, chars:, bytes: }
end

def calcurate_total(file_stats)
  stats = file_stats.values
  total = {
    total: stats[0].merge(*stats[1..]) { |_, old_value, new_value| old_value + new_value }
  }
  file_stats.merge(total)
end

def format_file_stats(file_stats:, filter_params:)
  col_width = max_col_width(file_stats)
  file_stats.map { |name, stat| format(stat:, filter_params:, col_width:) + " #{name}" }.join("\n")
end

def max_col_width(file_stats)
  file_stats.values.map do |stat|
    stat.values.max.to_s.size
  end.max
end

def format(stat:, filter_params:, col_width: 7)
  filtered_stat = stat.filter { |k| filter_params.keys[0..].include?(k) }.values
  filtered_stat.map { |v| v.to_s.rjust(col_width) }.join(' ')
end

__FILE__ == $PROGRAM_NAME && main
