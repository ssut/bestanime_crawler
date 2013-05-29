#encoding: utf-8

class BestAnime
	attr_accessor :data_cnt
	@@instance = nil

	def initialize
		@mutex = Mutex.new

		# 한글은 "심볼": "내용" 형태로 작성이 안됨
		@_title = {
			:"제목" => "title",
			:"원제" => "title_origin",
			:"영제" => "title_en",
			:"부제" => "title_sub",
			:"감독" => "director",
			:"원작" => "original",
			:"각본" => "screenplay",
			:"제작" => "publish",
			:"저작권" => "copyright",
			:"음악" => "music",
			:"장르" => "genre",
			:"제작년도" => "year",
			:"BA등급" => "ba_stars",
			:"구분" => "type",
			:"총화수" => "total_stories",
			:"제작국" => "publish_country"
		}

		@agent = Mechanize.new
		@agent.user_agent = 'w3m/0.52'
		page = @agent.post('http://bestanimation.co.kr/Member/ProcMember.php', {
			"Method" => "LOGIN",
			"Email" => $config["user_info"]["email"],
			"Password" => $config["user_info"]["password"]
		})

		if page.body.include?("errcode: 1")
			puts "login failed"
			exit
		elsif page.body.include?("errcode: 0")
			puts "login success"

			@data_cnt = 0
			@ani_cnt = get_ani_count
		end
	end

	def self.instance
		if @@instance == nil
			@@instance = new
		end

		return @@instance
	end

	def get_ani_count
		@agent.get("http://bestanimation.co.kr/Library/Animation/Search.php") do |page|
			html = Nokogiri::HTML(page.content)
			begin
				return html.css('font[class="sred"]')[0].content.gsub(',', '').to_i
			rescue
				puts "http error"
				exit
			end
		end
	end

	def start index
		return unless $_anime.find_one({ "bestani_index" => index }) == nil

		p "#{@data_cnt} | #{@ani_cnt}"

		html = Hash.new
		data = Hash.new

		html['info'] = Nokogiri::HTML(@agent.get("http://bestanimation.co.kr/Library/Animation/Info.php?Idx=#{index}").body)
		if html['info'].to_s.include?('나이체크가 필요한 데이터입니다. 로그인 해주세요.')
			puts "? BA-R"
			exit
		end

		unless html['info'].to_s.include?("alert('데이터가 없습니다.')")
			html['synopsys'] = Nokogiri::HTML(@agent.get("http://bestanimation.co.kr/Library/Animation/Synopsis.php?Idx=#{index}").body)
			html['character'] = Nokogiri::HTML(@agent.get("http://bestanimation.co.kr/Library/Animation/Character.php?Idx=#{index}").body)

			html['info'].css('table tr[height="24"]').each do |cont|
				title = cont.css('b')[0].content.to_s.gsub(/\t/, '').strip
				content = cont.css('td:last-child')[0].content.to_s.gsub(/\t/, '').strip

				data[@_title[title.to_sym]] = content
			end

			data['info'] = html['info'].css('table[width="820"] td')[0].content
			data['synopsys'] = html['synopsys'].css('table[width="820"] td')[0].content

			data['info'] = "" if data['info'] == '+'
			data['synopsys'] = "" if data['synopsys'] == '+'

			data['character'] = Array.new
			html['character'].css('table[width="820"] tr[height="30"]').each do |cont|
				next if cont.content.to_s.include?('캐릭터') && cont.content.to_s.include?('소개')

				img = cont.css('img')[0]['src']
				img = "http://bestanimation.co.kr" + img if img[0] == "/"

				img_filename = ''
				img_filename = img.split('/')[-1] unless img.include?('no_character_img.gif')

				if img.include?('no_character_img.gif') == false && $config['settings']['get_character_image'] == 1
					path = "./files/#{index}/"
					unless File.exists?(path)
						FileUtils.mkdir_p path
						FileUtils.chmod 0777, path
					end

					img_stream = File.open(path + img_filename, 'wb')
					open(img) do |stream|
						img_stream.write stream.read
					end
					img_stream.close
				end
				
				td = cont.css('td:last-child')[0].content.to_s.gsub(/\t/, '').gsub(/성우 : (.+)/i, '').strip.split("\r")
				actor = ''
				begin
					actor = cont.css('td:last-child u')[0].content.to_s.gsub(/\n/, '')
				rescue
					actor = ''
				end

				character_name = td[0].gsub(/\n/, '')
				td.shift
				desc = td.join('').gsub(/\n/, '')
				data['character'].push({
					'name' => character_name,
					'actor' => actor,
					'desc' => desc,
					'image' => img_filename
				})
			end
			push index, data
		end

		return true if @data_cnt >= @ani_cnt
	end

	def push(index, data)
		return unless $_anime.find_one({ "bestani_index" => index }) == nil

		_id = $_anime.insert({
			"title" => data["title"],
			"title_origin" => data["title_origin"],
			"title_en" => data["title_en"],
			"title_sub" => data["title_sub"],
			"director" => data["director"],
			"original" => data["original"],
			"screenplay" => data["screenplay"],
			"publish" => data["publish"],
			"copyright" => data["copyright"],
			"music" => data["music"],
			"genre" => data["genre"],
			"year" => data["year"],
			"ba_stars" => data["ba_stars"],
			"type" => data["type"],
			"total_stories" => data["total_stories"],
			"publish_country" => data["publish_country"],
			"info" => data["info"],
			"synopsys" => data["synopsys"],
			"bestani_index" => index
		})

		data["character"].each do |item|
			$_character.insert({
				"anime_id" => _id,
				"name" => item["name"],
				"actor" => item["actor"],
				"desc" => item["desc"],
				"image" => item["image"],
				"bestani_index" => index
			})
		end
		
		@data_cnt += 1
		p "#{index} : OK : #{data["title"]}"
	end

	private_class_method :new
	private :push
end