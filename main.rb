#!/usr/bin/env ruby

# TODO
# * bundler
require 'rubygems'  
require 'tweetstream'
require 'logger'

CONFIG = YAML.load(File.read('config.yml'))

# represents one show with a URL to the torrent file
class Torrent
  attr_accessor :url
  
  INCLUDE_REGEXP = Regexp.new(CONFIG[:includes].join("|"))
  EXCLUDE_REGEXP = Regexp.new(CONFIG[:excludes].join("|"))
  
  def initialize(tweet)
    if tweet =~ INCLUDE_REGEXP && !(tweet =~ EXCLUDE_REGEXP)
      @url = extract_url_from_tweet(tweet)
      $log.info "Interested in #{tweet}"
    else
      $log.info "Not interested in #{tweet}"
    end
  end
  
  def self.download(tweet)
    $log.info "Creating torrent from tweet #{tweet}"
    t = Torrent.new(tweet)
    if t.downloadable?
      $log.info "Downloading torrent from url #{t.url}"
      t.download
    end
  end
  
  def extract_url_from_tweet(tweet)
    tweet.scan(/(http:.*)$/).to_s
  end

  def downloadable?
    ! @url.nil?
  end
  
  def download
    `wget #{url}`
    file = File.basename(url)
    `transmission #{file}`
    `rm #{file}`
  end
end

$log = Logger.new(STDOUT)  #('log_file.log')
$log.info "Started muTorrent"

EZTV = 14557926
CARR = 14592420

#, 'mu_torrent'

TweetStream::Client.new(CONFIG[:username], CONFIG[:password]).follow(CARR) do |status|  
  $log.info "Status occured - #{status.text}"
  t = Torrent.download(status.text)
end