#encoding: utf-8

require 'rubygems'
require 'mongo'

require 'sinatra'
require 'sinatra/base'
require 'sinatra/partial'
require 'sinatra/static_assets'

require 'erb'
require 'less'
require 'net/http'
require 'open-uri'
require 'uri'
require 'erubis'
require 'json'

require 'nokogiri'
require 'mechanize'

include Mongo
$config = YAML.load(File.read('./config.yml'))
$client = MongoClient.new('localhost', 27017)
$db = $client.db($config["database"]["name"])

$_anime = $db.collection('animation')
$_character = $db.collection('character')

$root = Dir.pwd

class BCServer < Sinatra::Base
	set :root, $root
	set :public_folder, $root + '/server/public'
	set :views, $root + '/server/view'
	set :bind, '0.0.0.0'
	set :erb, :escape_html => true

	load "server/helpers.rb"
	load "server/routes.rb"
	load "server/partial.rb"
end
