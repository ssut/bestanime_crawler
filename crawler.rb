#encoding: utf-8

require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'mongo'

require 'json'
require 'open-uri'
require 'uri'
require 'yaml'
require 'fileutils'
require 'thread'
require './bestanime.rb'
include Mongo

$config = YAML.load(File.read('./config.yml'))
$client = MongoClient.new('localhost', 27017)
$db = $client.db($config["database"]["name"])

$_anime = $db.collection('animation')
$_character = $db.collection('character')

index = 0
BestAnime.instance.data_cnt = $_anime.find.count if $_anime.find.count > 0
$index = $_anime.find.sort(:bestani_index => :desc).limit(1).to_a[0]['bestani_index'] if $_anime.find.count > 0

loop do
	index += 1

	result = BestAnime.instance.start index
	break if result
end