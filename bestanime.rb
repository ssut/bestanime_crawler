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
	end

	def self.instance
		if @@instance == nil
			@@instance = new
		end

		return @@instance
	end

	def start
		html = Hash.new
		data = Hash.new

		html['info'] = Nokogiri::HTML(open("http://bestanimation.co.kr/Library/Animation/Info.php?Idx=#{$index}"))
		html['synopsys'] = Nokogiri::HTML(open("http://bestanimation.co.kr/Library/Animation/Synopsis.php?Idx=#{$index}"))
		html['character'] = Nokogiri::HTML(open("http://bestanimation.co.kr/Library/Animation/Character.php?Idx=#{$index}"))

		html['info'].css('table tr[height="24"]').each do |cont|
			title = cont.css('b')[0].content.to_s.gsub(/\t/, '').strip
			content = cont.css('td:last-child')[0].content.to_s.gsub(/\t/, '').strip
		
			data[@_title[title.to_sym]] = content
		end

		data['info'] = html['info'].css('table[width="820"] td')[0].content
		data['synopsys'] = html['synopsys'].css('table[width="820"] td')[0].content
	end

	private_class_method :new
end