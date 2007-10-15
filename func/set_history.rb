#!/usr/bin/env ruby
#
# 履歴操作用モジュール

# XML操作
require "rexml/document"

module Set_history

	include REXML

	# ログにグループ履歴を追加
	def add_grp(grpID,grpMark, tmpHis)
		tmpelem = REXML::Element.new("group")
		tmpelem.add_attribute("id", grpID)
		tmpelem.add_attribute("mark", grpMark)
		
		tmpHis.elements["exam"].add_element(tmpelem) # group要素の追加
		return tmpHis
	end

	# 出題したitemの履歴を追加
	def add_itm(grpID, itmID, tmpHis)
		tmpelem = Element.new("item")
		tmpelem.add_attribute("id", itmID)

		REXML::XPath.first(tmpHis, "//exam/group[@id=\"" + grpID + "\"]").add_element(tmpelem)
		#puts tmpHis.elements["exam"].elements["group"].attributes["id"].class#add_element(tmpelem)
		return tmpHis
	end

	# itemの履歴に付加情報を記録
	def add_inf2item(grpID, itmID, elem, tmpHis)
	#puts elem
	#puts grpID
	#puts itmID
	#puts tmpHis
		REXML::XPath.first(tmpHis, "//exam/group[@id=\"" + grpID + "\"]/item[@id=\"" + itmID + "\"]").add_element(elem)
		return tmpHis
	end

	# ログからevaluate要素を削除
	def delete_evaluate(grpID, itmID, tmpHis)
		tmpElm = tmpHis.get_elements("//exam/group[@id=\"" + grpID + "\"]/item[@id=\"" + itmID + "\"]")[0]
		tmpElm.delete_element("evaluate")
	end

	# ログから評価したスコアを取得
	def get_score_(grpID, itmID, tmpHis)
		tmpElem = tmpHis.get_elements("//exam/group[@id=\"" + grpID + "\"]/item[@id=\"" + itmID + "\"]/evaluate/score")[0]
		return tmpElem.text
	end

	# 評価結果を追加
	def add_evaluated_(grpID, itmID , score, checked, tmpHis)
		tmpElem = tmpHis.get_elements("//exam/group[@id=\"" + grpID + "\"]/item[@id=\"" + itmID + "\"]")[0]
		tmpElem.add_attribute("score", score)
		tmpElem.add_attribute("checked", checked)
		return checked
	end

	# item要素群を取る
	def get_items_(grpID, tmpHis)
		return tmpHis.get_elements("//exam/group[@id=\"" + grpID + "\"]/item")
	end

	# group要素をとる
	def get_groups_(tmpHis)
		return tmpHis.get_elements("//exam/group")
	end

	# 履歴を保存
	def save(filename, tmpHis)
		File.open(filename, "w"){|fp|
			fp.puts tmpHis
		}
	end

# ↓今の所未使用

	# ファイルからDocumentオブジェクトを生成
	def create_log()
		File.open("/func/history.xml") {|fp|
			# 空白のみのテキストノードを無視
			doc = REXML::Document.new(fp, {:ignore_whitespace_nodes => :all})
		}
		return doc
	end

	# ログが既に存在しているか
	def logExsist?
		return FileTest.exsist?("./func/history.xml")
	end

	# ログ中にユーザーIDが存在するか
	def uidExsist?(u_id, tmpHis)
		if tmpHis.element["history"].attribute[u_id] == nil then
			return false
		else
			return true
		end
	end

	# 学習者IDのログを作成
	def makelog4uid(u_id, tmpHis)
		tmpHis.elements["history_log"].add_attribute("uid", u_id) # 学習者ID?が入る予定
	end

	# 指定したユーザIDのログを返す
	def get_usrLog(u_id)
		@exam_log = @His.get_elements("/history_log[@uid = \"" + @uid + "\"]")[0]
	end
end