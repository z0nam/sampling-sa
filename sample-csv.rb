require 'csv'
require 'tempfile'

# csv 파일 합침
def merge_csv
  print "Merging CSV files...  "
  merged = Tempfile.open(['tweets', '.csv']) do |f|
    f << `cat #{$path}/*.csv`
  end
  puts "done."
  return merged
end

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

# 결과 파일 작성
def write_csv(csv_array)
  time = Time.new.strftime("%m%d-%H%M%S")
  filename = "#{File.basename($path)}-#{csv_array.length}-#{time}.csv" # arg0-arg1-time.csv
  CSV.open(filename, 'wb') do |csv|
    csv << csv_array[0].headers
    csv_array.each { |row| csv << row }
  end
  puts "#{filename} saved"
end

# main
get_arguments
csv = CSV.read(merge_csv, 'r', :encoding => 'UTF-8', :headers => :first_row)
write_csv(get_samples(csv))
