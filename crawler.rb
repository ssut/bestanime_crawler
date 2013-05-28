#encoding: utf-8

require 'rubygems'

require 'nokogiri'
require 'open-uri'
require 'uri'
require 'mongo'

require './bestanime.rb'

include Mongo

$Client = MongoClient.new('localhost', 27017, :pool_size => 5, :pool_timeout => 5)
$DB = $Client['bestanime_crawler']

$index = 1
BestAnime.instance.start