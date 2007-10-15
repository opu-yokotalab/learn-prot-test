#!/usr/bin/env ruby
#
# 解答評価プログラム

# REXML
require "rexml/document"
# 問題DBクラス
require "./func/test_db"
# 履歴クラス
require "./func/history"
# Ruby-xslt （要インストール）
require 'xml/xslt'

module Evaluate

	include REXML

	# プレ評価
	def pre_evaluate(params)
		# 間違えて呼ばれいていないか
		if params["mode"].to_s != "pre_evaluate" then
puts "mode is false."
			return false
		end

		# 解答形式により処理を分岐
		qs = params["type"].to_s
		eValue = nil
		case qs
			when "radio" then
				eValue = params["value"].to_s
				evaluate_radio(params)
			when "checkbox" then
				eValue = params["checked"].to_s
				return "non"
			when "text" then
				eValue = params["value"].to_s
				return "non"
			else # その他 or 拡張用
				eValue = "other"
				return "non"
		end

	end

	# 評価（radio用）
	def evaluate_radio(params)
		# 問題DBアクセス用
		t_db = Test_db.new
		# 履歴モジュール
		history = History.new("Test_id", "get")

		# 正解数
		correct = 0
		# 不正解数
		incorrect = 0

		# 履歴に追加する部分木
		elem = Element.new("evaluate")

		# eValueと正解を比較
		# プレ評価の結果をログに書き込む
		sAry = Array.new
		# selectedの値をグループID、問題ID、Valueに分割
		sAry = params["selected"].to_s.split("_")
	
		# グループID、問題IDを元に問題DBから該当する問題を取得

		# 問題DBを開く
		t_db.create_doc(sAry[0])

		# evaluate属性値を用いて計算
		cAry = Array.new
		cAry = t_db.get_correct(sAry[1]).to_s.split(",")

		# 評価
		if cAry.include?(params["value"].to_s) then
			correct += 1
		else
			incorrect += 1
		end

		# 正解数、不正解数の履歴を記録
		cNode = Element.new("correct")
		cNode.add_text(correct.to_s)
		cNode.add_attribute("weight", t_db.get_weight(sAry[1],"correct"))

		iNode = Element.new("incorrect")
		iNode.add_text(incorrect.to_s)
		iNode.add_attribute("weight", t_db.get_weight(sAry[1],"incorrect"))

		elem.add_element(cNode)
		elem.add_element(iNode)

		# 獲得したポイント
		pNode = Element.new("score")
		point = (correct.to_i * t_db.get_weight(sAry[1],"correct").to_i) + (incorrect.to_i * t_db.get_weight(sAry[1],"incorrect").to_i)
		pNode.add_text(point.to_s)

		elem.add_element(pNode)
#puts elem

		# 学習者が選んだ選択肢(Value)とその結果（正解、不正解数）をログに書き込む
#history.printHistory
#puts sAry[0] + "_" + sAry[1]
		history.del_evaluate(sAry[0], sAry[0] + "_" + sAry[1])
#history.printHistory
		history.add_info2item(sAry[0], sAry[0] + "_" + sAry[1], elem)
		history.saveHistory("./func/history.xml")
#puts "after"
#puts history.printHistory

		return point.to_s
#		return cAry.include?(params["value"].to_s)
	end


	# 解答確定
	def evaluate(params)
		# 問題DBアクセス用
		t_db = Test_db.new
		# 履歴モジュール
		history = History.new("Test_id", "get")

		# 引数
		sAry = Array.new
		# selectedの値をグループID、問題ID、Valueに分割
		sAry = params["name"].to_s.split("_")

		if sAry == nil then
			return false
		end
#puts sAry[0].to_s + "_" + sAry[1].to_s
		# 問題DBを開く
		t_db.create_doc(sAry[0].to_s)

		# 正解となる閾値
		tdbScore =  t_db.get_score(sAry[1].to_s)

		# 評価した結果
		hisScore =  history.get_score(sAry[0].to_s, sAry[0].to_s + "_" + sAry[1].to_s)
#puts tdbScore + " , " + hisScore

		# 評価結果の返り値
		res = "false"

		if tdbScore.to_i <= hisScore.to_i then # 閾値を超えた => 正解
			pnt = t_db.get_point(sAry[1].to_s)
			history.add_evaluated(sAry[0].to_s, sAry[0].to_s + "_" + sAry[1].to_s, pnt, "true")
			res = "true"

		else
			pnt = 0
			history.add_evaluated(sAry[0].to_s, sAry[0].to_s + "_" + sAry[1].to_s, pnt, "false")
			res = "false"
		end

		history.saveHistory("./func/history.xml")
#puts res.to_s

		# 解答と入れ替え
		elem = t_db.get_itembyID(sAry[1])
		elem.add_attribute("id", sAry[0] + "_" + sAry[1])
		elem.add_attribute("evaluate", res)
		dElem = Document.new()
		dElem.add(elem)
#puts dElem

		# xsltオブジェクト
		xslt = XML::XSLT.new()
		xslt.xml = dElem
		xslt.xsl = REXML::Document.new File.open( "./evaluate.xsl" )
		out = xslt.serve() # Stringオブジェクト
		outDoc = REXML::Document.new(out)

		if res == "true" then
			tElem = outDoc.get_elements("/div/div/h2")[0]
			str = "正解！"

		else
			tElem = outDoc.get_elements("/div/div/h2")[0]
			str = "不正解..."
		end
		tElem.add_text(Kconv.kconv(str, Kconv::UTF8))
#puts outDoc
#puts outDoc.get_elements("/div[@id=\"item_" + sAry[0] + "_" + sAry[1] + "\"]").to_s
		return outDoc.get_elements("/div[@id=\"item_" + sAry[0] + "_" + sAry[1] + "\"]").to_s

	end

	# グループ単位の評価
	def grp_evaluate
#puts "grp: "
		# 履歴モジュール
		history = History.new("Test_id", "get")

		tmpHash = Hash.new
		tmpScore = nil
		tmpInt = 0
		flg = true
#history.printHistory
#puts history.get_groups().class
		history.get_groups().each{|grps|
		tmpInt = 0
		flg = true
#puts grps
#puts grps.attribute("id").to_s
		tmpHash[grps.attribute("id").to_s] = nil
			history.get_items(grps.attribute("id").to_s).each{|itms|
				tmpScore = itms.attribute("score")
#puts tmpScore
				if tmpScore != nil then
					tmpInt = tmpInt + tmpScore.value.to_i
					#tmpHash[grps.attribute("id").to_s] = tmpInt
				else
					
					# 1箇所でも未評価
					#flg = false
					tmpInt = -1
					break
				end
			}
#puts tmpInt
#puts flg
			#if flg then
				tmpHash[grps.attribute("id").to_s] = tmpInt
			#end
		}
		return tmpHash
	end

end

# 試験動作用
if __FILE__ == $0 then
  eva = Evaluate.new
  p eva.get_history
  eva.response = {"q1" => ["0","1","2"], "q2" => ["2","3","4"], "q3" => ["0","1"]}
  r = Hash.new
  r = eva.evaluate_response
  p r
end
