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
#require "cgi"
# XML操作
require "rexml/document"
# 文字コード変換
require "kconv"
# テスト機構インタフェース
require "./func/mod_test"


class Adel_exam

	# XML操作
	include REXML
	# 共通定数
	# include Value
	# 呼び出し記述解釈と問合せ

	# コンストラクタ
	def initialize
		# QueryString取得
		#qs = CGI.new
    		#@params = qs.params
    		@params = Hash.new
		#@params = {"mode" => nil} # テスト用 #
		@params = {"mode" => "evaluate", "name" => "q1_3", "type" => "radio", "value" => "0"} # テスト用
		# REXML::Document
		@doc = nil
	end

	# オープン
	def create_doc()
		File.open("./examination_prot.xml") {|fp|
		# 空白のみのテキストノードを無視
		@doc = REXML::Document.new(fp, {:ignore_whitespace_nodes => :all})
		}
		lis = REXML::XPath.first(@doc,"//examination")
		return lis
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
		str = "<?xml version='1.0' encoding='UTF-8'?><!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"><html lang='ja' xml:lang='ja' xmlns='http://www.w3.org/1999/xhtml'>  <head>    <meta content='application/xhtml+xml; charset=UTF-8' http-equiv='Content-Type'/>  <meta http-equiv=\"Pragma\" content=\"no-cache\" /> <meta http-equiv=\"Cache-Control\" content=\"no-cache\" />  <link href='test_m.css' rel='stylesheet' type='text/css'/>    <title>■テスト機構プロトタイプ■</title>    <script type='text/javascript' src='./func/evaluate.js'><!--hoge--></script>  </head><body>"
		return str.kconv(Kconv::EUC, Kconv::UTF8)
		
	end

	# HTML尾部の書き出し
	def printHTMLFoot
		str = "</body></html>"
		return str.kconv(Kconv::EUC, Kconv::UTF8)
	end
	
end


adel = Adel_exam.new
#print adel.create_doc()
#print "\n"
#print adel.create_doc().class
#print "\n"
#出題モードでテスト機構インスタンス生成
m_test = Mod_test.new(adel.get_params)
#m_test.set_examination(adel.create_doc())
p adel.get_params
case m_test.get_mode(adel.get_params)
	when "set" then # 最初の呼び出し
		#print "Content-type: text/html\n\n"
		#print adel.printHTMLHead
		#print m_test.get_xhtmlAll(adel.create_doc())
		print m_test.get_xhtmlAll(adel.create_doc())
		#print adel.printHTMLFoot
	when "pre_evaluate" then # プレ評価
		#print "Content-type: text/html\n\n"
		print "<e_result>"
		print m_test.pre_evaluate(adel.get_params)
		print "</e_result>"
	when "evaluate" then # 解答確定
		print "Content-type: text/html\n\n"
		print m_test.evaluate(adel.get_params)
		p m_test.grp_evaluate
end

# m_test.print_tree
#p m_test.get_numGroup
#p m_test.get_order("q1")
#p m_test.get_numItem("q1")
