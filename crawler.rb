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
$client = MongoClient.new('localhost', 27017)
$db = $client.db($config["database"]["name"])

$client.database_info.each { |info| puts info.inspect }

$_anime = $db.collection('animation')
$_character = $db.collection('character')

$index = 0
loop do
	result = BestAnime.instance.start
	break if result
end