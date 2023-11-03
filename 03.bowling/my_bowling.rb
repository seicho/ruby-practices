# frozen_string_literal: true

score_sheet = ARGV[0]
score_sheet = score_sheet.split(',')
score_sheet_array = []

score_sheet.each do |c|
  if c.match?(/x/i)
    score_sheet_array << 10
    score_sheet_array << 0
  elsif c.to_i > 10
    raise 'This sheet includes invalid score'
  else
    score_sheet_array << c.to_i
  end
end
raise 'This sheet is invalid. You need to throw more' if score_sheet.size < 12

frames = []
score_sheet_array.each_slice(2) do |shots|
  frames << shots
end

if frames.size < 10 || ((frames[9][0] == 10 || frames[9].sum == 10) && frames.size < 11) || (frames[10][0] == 10 && frames.size < 12) || frames.size > 12
  raise 'This sheet is invalid'
end

total_score = 0
frame_counter = 0
frames.each.with_index do |frame, index|
  total_score += if frame[0] == 10 && frames[index + 1][0] == 10
                   frame[0] + frames[index + 1][0] + frames[index + 2][0]
                 elsif frame[0] == 10
                   frame[0] + frames[index + 1].sum
                 elsif frame.sum == 10
                   frame.sum + frames[index + 1][0]
                 else
                   frame.sum
                 end
  frame_counter += 1
  break if frame_counter == 10
end

p total_score
