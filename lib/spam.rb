# -*- coding: UTF-8 -*-

require 'MeCab'
require 'classifier'
require 'json/pure'

class Spam
	def initialize()
		@is_spam = false
		@bayes = Classifier::Bayes.new('spam','real')
		@wakati = MeCab::Tagger.new('-O wakati')
		@real_file_path = "/var/spam_filter/real.json"
		@spam_file_path = "/var/spam_filter/spam.json"
		@spams = []
		@reals = []
		ret = json2bayes()
		abort("Can't read json") if(ret == false)
	end
	def json2bayes()
		begin
			open(@spam_file_path,'r') do |io|
				json = io.read.to_s.force_encoding("UTF-8")
				json_spam = JSON.parse(json)
				set_spam()
				json_spam.each do |rec|
					study(rec.to_s)
				end
			end
			open(@real_file_path,'r') do |io|
				json = io.read.to_s.force_encoding("UTF-8")
				json_real = JSON.parse(json)
				set_real()
				json_real.each do |rec|
					study(rec.to_s)
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
			io = File.open(@spam_file_path,'w')
			io.puts JSON.pretty_generate(@spams)
			io.close
		
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
	def to_spam(str = "")
		@spams.push(str) 
		return
	end
	def to_real(str = "")
		@reals.push(str) 
		return
	end
end
