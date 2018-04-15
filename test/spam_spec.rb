
require 'drb/drb'
require 'minitest/autorun'

DRb.start_service

class DrbSpam < Minitest::Test
  def setup
    @obj = DRbObject.new_with_uri('druby://localhost:50010')

    @obj.spam = true
    @obj.study('エロ動画お得')
    @obj.study('ダウンロード')

    @obj.spam = false
    @obj.study('こんばんわ')
    @obj.study('こんにちわ')
    @obj.study('ちわっす')
  end

  def test_real
    assert_equal @obj.judgment('おはよう'), 'Real'
  end

  def test_spam
    assert_equal @obj.judgment('エロ動画(笑)'), 'Spam'
  end

  def test_save_json
    @obj.to_json_file
    assert_equal File.exist?(@obj.real_file_path), true
    assert_equal File.exist?(@obj.spam_file_path), true
  end
end
