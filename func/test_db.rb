#!/usr/bin/env ruby
#
# テスト機構プロトタイプ
# 問題呼出用クラス

# XML操作
require "rexml/document"
# 文字コード変換
require "kconv"
# 履歴
#require "./test/history"

class Test_db

  # XML操作
  include REXML

	def initialize()
		@doc = nil
		#create_doc(filename)
	end

	def create_doc(filename)
		File.open("./db/" + filename + ".xml") {|fp|
			# 空白のみのテキストノードを無視
			@doc = REXML::Document.new(fp, {:ignore_whitespace_nodes => :all})
		}
	end

	def get_itembyID(item_id)
		# 返り値がArrayクラスなので、REXML::Elementにするために最初の要素だけ取得
		e_ary = @doc.get_elements("/problem_set/item[@id=\"" + item_id + "\"]")
		return e_ary[0]
	end

#	def get_itembyType(item_type, ary)
# 旧
#		elems = @doc.elements.to_a("/problem_set/item[@type=\"" + item_type + "\"]").collect
#		r_num = rand(elems.length)
#		
#		return elems[r_num]
#	end

	def get_IDbyRand(ary)
		attrTmpAry = Array.new
		# group内のitem要素数からランダムで1つ決定
		elems =  @doc.elements.to_a("/problem_set/item").collect

		# 該当するitem要素のid群を取得
		elems.each{|e|
			attrTmpAry << e.attributes["id"]
		}

		# 既に決定されたid群と差を取る。要素が無ければ出題の余地なし
		attrTmpAry = attrTmpAry - ary
		if attrTmpAry.length == 0 then
			return false
		end
#puts "Length: " + attrTmpAry.length.to_s
		r_num = rand(attrTmpAry.length)
#puts "r_num: " + r_num.to_s
#print "attrTmpAry: "
#p attrTmpAry
#print "ary: "
#p ary
		return attrTmpAry[r_num]
# 旧
#		# 返り値がArrayクラスなので、REXML::Elementにするために最初の要素だけ取得
#		e_ary = @doc.get_elements("/problem_set/item[@id=\"" + r_num.to_s + "\"]")
#		return e_ary[0]
	end

	def get_IDbyType(item_type, ary)
		attrTmpAry = Array.new
		elems = @doc.get_elements("/problem_set/item[@type=\"" + item_type + "\"]")
		# 該当するitem要素のid群を取得
		elems.each{|e|
			attrTmpAry << e.attributes["id"]
		}

		# 既に決定されたid群と差を取る。要素が無ければ出題の余地なし
		attrTmpAry = attrTmpAry - ary
		if attrTmpAry.length == 0 then
			return false
		end
#puts "Length: " + attrTmpAry.length.to_s
		r_num = rand(attrTmpAry.length)
#puts "r_num: " + r_num.to_s
		return attrTmpAry[r_num]
	end

	def get_evaluate(item_id)
		return @doc.get_elements("/problem_set/item[@id=\"" + item_id + "\"]/evaluate")[0]
	end

	def get_correct(item_id)
		return get_evaluate(item_id).elements["correct"].attribute("id")
	end

	def get_score(item_id)
		tmpElem = get_evaluate(item_id).get_elements("./score")[0]
		return tmpElem.text
	end

	def get_weight(item_id, mode)
		return get_evaluate(item_id).elements["weight"].attribute(mode).to_s
	end

	def get_point(item_id)
		tmpElem = get_evaluate(item_id).get_elements("./point")[0]
		return tmpElem.text
	end

end


# 試験動作用
if __FILE__ == $0 then
	prot = Test_db.new("q1")
	#prot.create_doc("q1")
	puts prot.get_itembyID("0")
end
