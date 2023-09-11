# frozen_string_literal: true

require 'optparse'
require 'date'
parameters = ARGV.getopts('y:', 'm:')

def print_calender(first_day, last_day)
  first_line_indent = first_day.wday

  print "#{first_day.strftime('%B')} #{first_day.year}".center(23)
  puts

  %w[Su Mo Tu We Th Fr Sa].each do |x|
    print x.rjust(3)
  end
  puts

  first_line_indent.times do
    print '   '
  end

  (first_day..last_day).each do |x|
    if x == Date.today
      print "\e[7m#{x.day.to_s.rjust(3)}\e[0m"
    else
      print x.day.to_s.rjust(3)
    end
    puts if x.saturday?
  end
  puts
end

def validate_month(month)
  return unless month.to_i < 1 || month.to_i > 12

  print "cal: #{month} is neither a month number (1..12) nor a name"
  puts
  exit
end

input_year = parameters['y']
input_month = parameters['m']
validate_month(input_month) if input_month
today = Date.today

year = input_year || today.year
month = input_month || today.month

first_day = Date.new(year.to_i, month.to_i, 1)
last_day = Date.new(year.to_i, month.to_i, -1)

print_calender(first_day, last_day)
