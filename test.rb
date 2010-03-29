#!/usr/bin/env ruby
require 'rubygems'  
require 'tweetstream'

CARR = 14592420

TweetStream::Daemon.new('carr_', 'rfranck').follow(CARR) do |status|  
  File.open('/Users/carr/Projects/mu_torrent/test.log', 'w+') do |f|
    puts status.text
    f.puts "Status occured - #{status.text}"
  end
end