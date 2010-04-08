#!/opt/local/bin/ruby

strings = []

ARGV.each do |filename|
  File.open(filename).read.scan(/_\(@(.*?)\)/) do |m|
    strings << m
  end
end

puts strings.uniq.sort
