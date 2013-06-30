require 'csv'
require 'io/console'
require 'tempfile'

# 매개값 처리: 정수면 개수, 소수면 퍼센트 @done
# 매개값 처리: target folder @done
# csv 파일 전부 합침: tempfile 생성 @done
# Tag 입력 @done
# Tag 저장 @done
# csv 결과 파일 생성 @done
# tagging한 개수 저장 @done
# 처리할 총 개수 표시 @done
# return to previous tweet @done
# 샘플파일 생성 / 태깅 기능 분리
# 샘플 개수 기본값? @done
# args 순서 바꿈? @done


# csv 파일 합침
def merge_csv
  print "Merging CSV files...  "
  merged = Tempfile.open(['tweets', '.csv']) do |f|
    f << `cat #{$path}/*.csv`
  end
  puts "done."
  return merged
end

# c1 = CSV.new("TweetId,UserId,UserScrName,WriteTime,tweetString,TweetClass,RTseed,ReplySeed", :headers => :first_row)

# 매개값 처리
def wrong_arguments
    puts "Usage: ruby #{__FILE__} target-folder [sample-number]"
    exit
end

# DEFAULT_PATH = 'CSVs'
SAMPLE_NUMBER = 10
def get_arguments
  # $path = File.expand_path(ARGV[0].nil? ? DEFAULT_PATH : ARGV[0])
  unless ARGV[0].nil?
    $path = File.expand_path(ARGV[0])
  else
    wrong_arguments
  end

  number = ARGV[1].to_f
  if number >= 1
    $sample_number = number.to_i
  elsif number > 0 and number < 1
    $sample_number = (csv.length * number).round
  elsif ARGV[1].nil?
    $sample_number = SAMPLE_NUMBER
  else
    wrong_arguments
  end
end

# 난수 발생시켜 샘플 생성
def get_samples(csv)
  row_id = []
  sample = []
  $sample_number.times do
    begin
      r = rand(0...csv.length)
    end while row_id.include? r or csv[r]['TweetId'] == 'TweetId'
    row_id << r
    sample << csv[r]
  end
  return sample
end

# 트윗 출력하고 의견 받기
def tagging(tweet, id)
  signs = ["[1]Positive", "[2]Negative", "[3]Neutral", "[4]ETC"]
  sign = tweet['TAG'].nil? ? '' : " <<" + signs[tweet['TAG'].to_i - 1] + ">>"
  print "\n[#{id+1}/#{$sample_number}] "
  puts "#{tweet['tweetString']} #{sign}"
  print "([1]Positive [2]Negative [3]Neutral [4]ETC [B]ack [L]ast [G]oto [Q]uit) => "
  STDIN.getch
end

# 결과 파일 작성
def write_csv(csv_row)
  time = Time.new.strftime("%m%d-%H%M%S")
  filename = "#{File.basename($path)}-#{csv_row.length}-#{time}.csv" # arg0-arg1-time.csv
  CSV.open(filename, 'wb') do |csv|
    csv << csv_row[0].headers
    (csv_row.select { |row| row["TAG"] != nil }).each do |row|
      csv << row
    end
  end
  puts "#{filename} saved"
end

# main
get_arguments
csv = CSV.read(merge_csv, 'r', :encoding => 'UTF-8', :headers => :first_row)
sample_tweet = get_samples(csv)

tagged = 0
begin
  tag = tagging(sample_tweet[tagged], tagged)
  case tag
  when '1'..'4'
    puts "OK, #{tag}"
    sample_tweet[tagged]["TAG"] = tag
    tagged += 1
  when 'b'
    if tagged == 0
      puts "first tweet"
    else
      puts "return to previous tweet"
      tagged -= 1
    end
  when 'l'
    last = sample_tweet.find { |row| row["TAG"] == nil }
    tagged = sample_tweet.index(last)
    puts
  when 'g'
    print "goto line: "
    line = STDIN.gets
    if (1..sample_tweet.length) === line.to_i
      puts "goto #{line}"
      tagged = line.to_i - 1
    end
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
