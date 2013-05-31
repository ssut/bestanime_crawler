#encoding: utf-8

Sinatra::Base.get '/style/common.css' do
	less :"../public/common"
end

Sinatra::Base.get '/anime/:id/poster.jpg' do
	poster = $root + "/files/#{params[:id]}/poster.jpg"
	puts params[:id]
	puts poster

	unless File.exists?(poster)
		puts "not exists"
		content_type "image/gif"
		send_file $root + "/files/no_ani_img.gif"
	else
		puts "exists"
		content_type "image/jpeg"
		send_file poster
	end
end

