#encoding: utf-8

class BestAnime
	@@instance = nil

	def initialize
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

	def start
		$index += 1

		html = Hash.new
		data = Hash.new

		html['info'] = Nokogiri::HTML(@agent.get("http://bestanimation.co.kr/Library/Animation/Info.php?Idx=#{$index}").body)
		html['synopsys'] = Nokogiri::HTML(@agent.get("http://bestanimation.co.kr/Library/Animation/Synopsis.php?Idx=#{$index}").body)
		html['character'] = Nokogiri::HTML(@agent.get("http://bestanimation.co.kr/Library/Animation/Character.php?Idx=#{$index}").body)

		if html['info'].to_s.include?('나이체크가 필요한 데이터입니다. 로그인 해주세요.')
			puts "? BA-R"
			exit
		end

		unless html['info'].to_s.include?('데이터가 없습니다.')
			html['info'].css('table tr[height="24"]').each do |cont|
				title = cont.css('b')[0].content.to_s.gsub(/\t/, '').strip
				content = cont.css('td:last-child')[0].content.to_s.gsub(/\t/, '').strip

				data[@_title[title.to_sym]] = content
			end

			data['info'] = html['info'].css('table[width="820"] td')[0].content
			data['synopsys'] = html['synopsys'].css('table[width="820"] td')[0].content

			@data_cnt += 1
			push $index, data
		end

		return true if @data_cnt > @ani_cnt
	end

	def push(index, data)
		p "#{index} : OK : #{data["title"]}"
	end

	private_class_method :new
	private :push
end