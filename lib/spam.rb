
require 'mecab'
require 'classifier'
require 'json/pure'

# spam filter by classifier author: Hiroaki Kanazawa
class Spam
  def initialize
    @bayes = Classifier::Bayes.new('spam', 'real')
    @wakati = MeCab::Tagger.new('-O wakati')
    @real_file_path = './data/real.json'
    @spam_file_path = './data/spam.json'
    @spams = {}
    @reals = {}
    @spam = false
    json2bayes_spam
    json2bayes_real
  end
  attr_accessor :spam, :real_file_path, :spam_file_path

  def json2bayes_spam
    return unless File.exist?(@spam_file_path)
    File.open(@spam_file_path, 'r') do |io|
      json = io.read.to_s.force_encoding('UTF-8')
      json_spam = JSON.parse(json)
      @spam = true
      json_spam.keys.each do |key|
        study(key.to_s)
      end
    end
  end

  def json2bayes_real
    return unless File.exist?(@real_file_path)
    File.open(@real_file_path, 'r') do |io|
      json = io.read.to_s.force_encoding('UTF-8')
      json_real = JSON.parse(json)
      @spam = false
      json_real.keys.each do |key|
        study(key.to_s)
      end
    end
  end

  def study(set_str = '')
    if @spam == true
      to_spam(set_str)
      @bayes.train('spam', @wakati.parse(set_str))
    else
      to_real(set_str)
      @bayes.train('real', @wakati.parse(set_str))
    end
    self
  end

  def to_json_file
    json_mkdir(@spam_file_path)
    io = File.open(@spam_file_path, 'w')
    io.puts JSON.pretty_generate(@spams)
    io.close

    json_mkdir(@real_file_path)
    io = File.open(@real_file_path, 'w')
    io.puts JSON.pretty_generate(@reals)
    io.close
  end

  def judgment(check_str = '')
    raise if check_str.empty?
    @bayes.classify(@wakati.parse(check_str)).to_s
  end

  private

  def json_mkdir(file_path)
    raise if file_path.nil?
    dir = file_path
    dir = dir.sub(%r{/[a-zA-Z0-9\-_]+\.json$}, '')
    Dir.mkdir(dir) unless File.exist?(dir)
  end

  def to_spam(str)
    raise if str.nil?
    @spams[str] = 1
  end

  def to_real(str)
    raise if str.nil?
    @reals[str] = 1
  end
end
