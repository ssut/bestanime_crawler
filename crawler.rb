#encoding: utf-8

require 'rubygems'

require 'mechanize'
require 'nokogiri'
require 'mongo'

require 'json'
require 'open-uri'
require 'uri'
require 'yaml'

require './bestanime.rb'

include Mongo

$config = YAML.load(File.read('./config.yml'))
$client = MongoClient.new('localhost', 27017, :pool_size => 5, :pool_timeout => 5)
$db = $client['bestanime_crawler']

$index = 0
loop do
	result = BestAnime.instance.start
	break if result
end