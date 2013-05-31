#encoding: utf-8

Sinatra::Base.get '/' do
	@ani_jp = Array.new

	content = open('http://json.dcinside.com/nowbest/nowbest_ani1_new1.php').read
	list = JSON.parse(content[1, content.length - 3])

	list.each do |hash|
		@ani_jp.push({
			url: "http://gall.dcinside.com/list.php?id=ani1_new1&no=#{hash["no"]}",
			title: hash["subject"]
		})
	end

	@anime_cnt = number_format $_anime.count
	@character_cnt = number_format $_character.count

	erb :index
end

Sinatra::Base.post '/search' do
	if params.has_key?(:keyword) || params.has_key?(:type) || params.has_key?(:skip)
		JSON.generate({ "error" => 1 })
		return
	end

	result = Hash.new

	keyword = params[:keyword]
	type = params[:type]
	skip = params[:skip].to_i
	
	anime_count = $_anime.count
	character_count = $_character.count

	if type != 'animation' && type != 'character' && type != 'actor'
		JSON.generate({ "error" => 1 })
		return
	end

	if type == 'animation'
		data = $_anime.find({
			:$or => [
				{ :title =>  Regexp.new(Regexp.escape(keyword), Regexp::IGNORECASE) },
				{ :title_en => Regexp.new(Regexp.escape(keyword), Regexp::IGNORECASE) },
				{ :title_orign => Regexp.new(Regexp.escape(keyword), Regexp::IGNORECASE) }
			]
			}).sort({
				:bestani_index => :desc
			}).skip(skip).limit(10)

		result['total_count'] = data.count false
		if data.count == 0
			result['count'] = 0
		else
			result['count'] = data.count true
		end

		result['item'] = Array.new
		data.each do |item|
			hash = Hash.new

			item.each do |a,b|
				if a != "_id"
					hash[a] = b
				end
			end

			result['item'].push hash
		end

		result['skip'] = skip + 10
		result['skip'] = result['total_count'] if result['skip'] >= result['total_count']

		JSON.generate(result)
	end
end