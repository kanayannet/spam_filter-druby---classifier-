#!/bin/env /usr/local/bin/ruby-1.9.2-p290
# -*- coding: UTF-8 -*-

require 'drb/drb'
require 'rspec'

DRb.start_service

describe "drb + spam_filter" do
	before do
		@obj = DRbObject.new_with_uri('druby://localhost:50010')
	end
	it "spam の文章を学習" do
		@obj.set_spam.study("エロ動画お得")
		@obj.set_spam.study("ダウンロード")
	end
	it "非spam の文章を学習" do
		@obj.set_real.study("こんばんわ")
		@obj.set_real.study("ちわっす")
	end
	it "spam か real か判断(Real になるべき)" do
		@obj.judgment("おはよう").to_s.should == 'Real'
	end
	it "json に保存できたか?" do
		@obj.to_json_file().should == true
	end
end
