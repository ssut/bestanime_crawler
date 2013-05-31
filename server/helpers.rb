#encoding: utf-8

def number_format num
	return num.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
end

helpers do	
end