# frozen_string_literal: true

score_sheet = ARGV[0]
score_sheet = score_sheet.split(',')
score_sheet_array = []

score_sheet.each do |c|
  if c == 'x'
    score_sheet_array << 10
  elsif c.to_i > 10
    raise 'This sheet includes invalid score'
  else
    score_sheet_array << c.to_i
  end
end

raise 'This sheet is invalid. You need to throw more' if score_sheet.size < 12

total_score = 0
frame = []
frame_counter = 1
game_finished = false

score_sheet_array.each.with_index do |score, index|
  case frame_counter
  when 1..9
    if score == 10 && frame == []
      total_score += score + score_sheet_array[index + 1] + score_sheet_array[index + 2]
      frame_counter += 1
    else
      frame << score
      if frame.size == 2 && frame.sum == 10
        total_score += frame.sum + score_sheet_array[index + 1]
        frame = []
        frame_counter += 1
      elsif frame.size == 2
        total_score += frame.sum
        frame = []
        frame_counter += 1
      end
    end
  when 10
    frame << score
    if frame.size == 2 && frame.sum < 10
      total_score += frame.sum
      frame_counter += 1
      game_finished = true
    elsif frame.size == 3
      total_score += frame.sum
      frame_counter += 1
      game_finished = true
    end
  when 11
    raise 'This is an invalid score sheet. Frame is over 10.'
  end
end

raise 'You need to throw a ball again' if game_finished == false

print total_score
