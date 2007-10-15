#!/usr/bin/env ruby
#
# ■テスト機構プロトタイプ
# ver 0.0.1
# 作成日 06/09/12
# 最終更新日 06/09/12

# Documentオブジェクトを作成
# テスト記述要素を解釈、問合せを行うメソッドに投げる
# 返り値は既に生成したXHTMLか、問題の値を保持したクラスのインスタンス？
# 返り値を、表示するXHTMLの雛形とマージ


# QueryString取得
require "cgi"
# 文字コード変換
require "kconv"

require "./func/hhistory"

class Result

	# コンストラクタ
	def initialize
		# QueryString取得
		qs = CGI.new
    		@params = qs.params
		#@params = {"q1" => "0", "q2" => "1", "q3" => "2"} # テスト用
	end

	# 動作モードを返す（初回の出題、1問ごとの評価、など）
	def get_Mode
		return @params["mode"].to_s
	end

	# 引数のハッシュを取得
	def get_params
		return @params
	end

	# HTML頭部の書き出し
	def printHTMLHead
		str = "<?xml version='1.0' encoding='UTF-8'?><!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"><html lang='ja' xml:lang='ja' xmlns='http://www.w3.org/1999/xhtml'>  <head>    <meta content='application/xhtml+xml; charset=UTF-8' http-equiv='Content-Type'/>  <meta http-equiv=\"Pragma\" content=\"no-cache\" /> <meta http-equiv=\"Cache-Control\" content=\"no-cache\" />  <link href='test_m.css' rel='stylesheet' type='text/css'/>    <title>■テスト機構プロトタイプ■</title>    <script type='text/javascript' src='./func/evaluate.js'><!--hoge--></script>  </head><body>\n"
		return str.kconv(Kconv::EUC, Kconv::UTF8)
		
	end

	# HTML尾部の書き出し
	def printHTMLFoot
		str = "</body></html>"
		return str.kconv(Kconv::EUC, Kconv::UTF8)
	end
	
end


rslt = Result.new
hh = Hhistory.new

hHash = Hash.new
str = ""

print "Content-type: text/html\n\n"
print rslt.printHTMLHead

hHash = hh.history_gets
#p hHash
hHash.each{|key, value|
	str = "グループ" + key + "の得点： " + value + " 点<br />"
	print Kconv.kconv(str, Kconv::UTF8)
}


print rslt.printHTMLFoot

# m_test.print_tree
#p m_test.get_numGroup
#p m_test.get_order("q1")
#p m_test.get_numItem("q1")
