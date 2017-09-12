# -*- coding: UTF-8 -*-

require 'mecab'
require 'classifier'
require 'json/pure'

class Spam
	def initialize()
		@is_spam = false
		@bayes = Classifier::Bayes.new('spam','real')
		@wakati = MeCab::Tagger.new('-O wakati')
		@real_file_path = "/var/spam_filter/real.json"
		@spam_file_path = "/var/spam_filter/spam.json"
		@spams = {}
		@reals = {}
		ret = json2bayes()
		abort("Can't read json") if(ret == false)
	end
	def json2bayes()
		begin
			if(File.exists?(@spam_file_path) == true)

				open(@spam_file_path,'r') do |io|
					json = io.read.to_s.force_encoding("UTF-8")
					json_spam = JSON.parse(json)
					set_spam()
					json_spam.each do |key,val|
						study(key.to_s)
					end
				end
			end
			if(File.exists?(@real_file_path) == true)
				open(@real_file_path,'r') do |io|
					json = io.read.to_s.force_encoding("UTF-8")
					json_real = JSON.parse(json)
					set_real()
					json_real.each do |key,val|
						study(key.to_s)
					end
				end
			end
			return true
		rescue
			return false
		end
	end
	def set_spam()
		@is_spam = true
		return self
	end
	def set_real()
		@is_spam = false
		return self
	end
	def study(set_str = "")
		if(@is_spam == true)
			to_spam(set_str)
			@bayes.train('spam', @wakati.parse(set_str))
		else
			to_real(set_str)
			@bayes.train('real', @wakati.parse(set_str))
		end
		return self
	end
	def to_json_file()
		begin
			json_mkdir(@spam_file_path)
			io = File.open(@spam_file_path,'w')
			io.puts JSON.pretty_generate(@spams)
			io.close
		
			json_mkdir(@real_file_path)
			io = File.open(@real_file_path,'w')
			io.puts JSON.pretty_generate(@reals)
			io.close
			return true
		rescue
			return false
		end
	end
	def judgment(check_str = "")
		return @bayes.classify(@wakati.parse(check_str)).to_s
	end
	
	private
	def json_mkdir(file_path)
		dir = file_path
		dir = dir.sub(/\/[a-zA-Z0-9\-_]+\.json$/,"")
		if File.exists?(dir) == false
			Dir.mkdir(dir)
		end
	end
	def to_spam(str = "")
		@spams[str] = 1 
		return
	end
	def to_real(str = "")
		@reals[str] = 1
		return
	end
end
