require "optparse"
require "date"
opt = OptionParser.new
parameters = ARGV.getopts("y:", "m:")

def print_calender(date,e)
  counter = 0
  empty = e 
  today_day = 0
 
  print "#{date.month}月 #{date.year}".center(21) + "\n"
  
  ["日","月","火","水","木","金","土"].each do |x|
    print x.rjust(2)
  end
  print "\n"

  #1週目のインデントを作成
  empty.times do |x|
    print "".rjust(3)
    counter += 1
  end

  #渡されたDateオブジェクトの年・月が現在の年・月と一致しているか判定
  if date.year == Date.today.year && date.month == Date.today.month
    today_day = Date.today.day
  end
 
  (1..date.day).each do |x|
    if x == today_day
      print "\e[31m\e[47m#{x.to_s.rjust(3)}\e[0m"
    else
      print x.to_s.rjust(3)
    end
    counter += 1
    if counter == 7 
      print "\n"
      counter = 0
    end
  end
  puts ""
  #最後に％が表示されてしまうのを防ぐために追加
end
#1-12以外の月が入力された際の処理
if parameters["m"].to_i < 1 || parameters["m"].to_i > 12
  print "cal: #{parameters["m"]}は月を示す数字ではありません"
  exit
end

#コマンドラインオプションに応じてprint_calenderに渡す引数を定義
if parameters["y"] && parameters["m"]
  date =  Date.new(parameters["y"].to_i,parameters["m"].to_i,-1)
  indent_for_first_week = Date.new(parameters["y"].to_i,parameters["m"].to_i,1).wday
elsif parameters["m"]
  date = Date.new(Date.today.year,parameters["m"].to_i,-1)
  indent_for_first_week = Date.new(Date.today.year,parameters["m"].to_i,1).wday
else
  date = Date.new(Date.today.year,Date.today.month,-1)
  indent_for_first_week = Date.new(Date.today.year,Date.today.month,1).wday
end

print_calender(date, indent_for_first_week)
