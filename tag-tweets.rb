require 'csv'
require 'io/console'

# 매개값 처리
def wrong_arguments
    puts "Usage: ruby #{__FILE__} csv-file"
    exit
end

def get_arguments
  unless ARGV[0].nil?
    $path = File.expand_path(ARGV[0])
  else
    wrong_arguments
  end
end

# 트윗 출력하고 의견 받기
def tagging(tweet, id, sample_number)
  signs = ["", "[1]Positive", "[2]Negative", "[3]Neutral", "[4]ETC"]
  sign = tweet[id]['TAG'].nil? ? '' : " <<" + signs[tweet[id]['TAG'].to_i] + ">>"
  # if tweet.count { |row| row["TAG"] == nil } == 0
  if tweet[0]['TAG']
    tagged = tweet.count { |row| row["TAG"] == '1' or row["TAG"] == '2' or row["TAG"] == '3' }
  else
    tagged = 0
  end

  print "\n[#{tagged};#{id+1}/#{sample_number}] "
  # print "\n[#{id+1}/#{sample_number}] "
  puts "#{tweet[id]['tweetString']} #{sign}"
  print "([1]Positive [2]Negative [3]Neutral [4]ETC [M]ore) => "
  key = STDIN.getch
  if key == 'm'
    print "\n([1]Positive [2]Negative [3]Neutral [4]ETC [S]tatus [B]ack [F]orward [L]ast [G]oto [Q]uit) => "
    key = STDIN.getch
  end
  return key
end

# 결과 파일 작성
def write_csv(csv_array)
  # time = Time.new.strftime("%m%d-%H%M%S")
  filename = $path
  CSV.open(filename, 'wb') do |csv|
    csv << csv_array[0].headers
    csv_array.each do |row|
      csv << row
    end
  end
  puts "#{File.basename(filename)} saved"
end

# 태깅 안된 트윗 찾기
def find_untagged(tweet)
  last = tweet.find { |row| row["TAG"] == nil }
  puts "to first untagged tweet"
  tweet.index(last)
end

# 태깅한 개수 세기
def count_tag(array, tag)
  array.count { |row| row["TAG"] == tag }
end

# 상태 표시
def show_status(tweet)
  tagged_detail = "(#{count_tag(tweet, "1")}/#{count_tag(tweet, "2")}/#{count_tag(tweet, "3")}/#{count_tag(tweet, "4")})"
  total = tweet.length
  untagged = count_tag(tweet, nil)
  puts "Tagged:#{total - untagged}#{tagged_detail}, Untagged:#{untagged}, Total:#{total}"
end

# main
get_arguments
begin
  csv = CSV.read($path, 'r', :encoding => 'UTF-8', :headers => :first_row)
  sample_tweet = []
  csv.each { |row| sample_tweet << row }
rescue
  puts "wrong filename."
  wrong_arguments
end

tagged = find_untagged(sample_tweet)
tagged = 0 if tagged.nil?
show_status(sample_tweet)
begin
  tag = tagging(sample_tweet, tagged, sample_tweet.length)
  case tag
  when '1'..'4'
    puts "OK, #{tag}"
    sample_tweet[tagged]["TAG"] = tag
    tagged += 1
  when 'b'
    unless tagged == 0
      puts "previous tweet"
      tagged -= 1
    else
      puts "first tweet"
    end
  when 'f'
    if tagged < sample_tweet.length - 1
      puts "next tweet"
      tagged += 1
    else
      puts "last tweet"
    end
  when 'g'
    print "goto line: "
    line = STDIN.gets
    if (1..sample_tweet.length) === line.to_i
      puts "goto #{line}"
      tagged = line.to_i - 1
    end
  when 'l'
    tagged = find_untagged(sample_tweet)
  when 's'
    show_status(sample_tweet)
  when 'q'
    print "save & quit? (Y/N/C)"
    case STDIN.getch
    when 'y'
      puts
      write_csv(sample_tweet)
      exit
    when 'n'
      puts '', "file not saved."
      exit
    end
    puts
  else
    puts "illegal command"
  end
end until tagged >= sample_tweet.length
write_csv(sample_tweet)
