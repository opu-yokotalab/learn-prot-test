#!/usr/bin/env ruby
#
# ■テスト機構プロトタイプ
# 出題モジュール
# 作成日 06/09/12
# 最終更新日 06/09/12

# XML操作
require "rexml/document"
# Ruby-xslt （要インストール）
require 'xml/xslt'
# 文字コード変換
require "kconv"
# 問題DBアクセス用
require "./func/test_db"
# 入力順を保持するハッシュクラス
require "./func/OHash"
# 出題ログ用モジュール
require "./func/history"

module Set_problem

	include REXML

	# 配列のシャッフル
	def randArray(ary)
		ary.each_index{|i|
			j = rand(i+1)
			ary[i], ary[j] = ary[j], ary[i]
		}
		return ary
	end

	# 問題の問合せ記述を解釈し、中間XMLを生成
	def get_xhtmlAll(inDoc)
		if inDoc == nil then # 呼び出し記述をもらっていない
			return false
		end

		# 問題DBアクセス用オブジェクト
		t_db = nil
		# 履歴用オブジェクト
		history = nil

		# documentオブジェクト
		tmpDoc = Document.new() # 中間xml
		outDoc = Document.new() # 出力用xhtml

		#問題DB
		t_db  = Test_db.new
		# 履歴モジュール
		history = History.new("Test_id", "put")

		# 出題する問題格納用配列
		itemAry = Array.new
		# 出題準備用ハッシュ（初期）
		tmpOHash = OHash.new
		# テスト記述記録用配列
		eAry = Array.new
		# 出題準備用ハッシュ（決定済みidのみ）
		itemOHash = OHash.new
		# 出題順格納リスト
		setAry = Array.new
		setOHash = OHash.new
		# 出題準備用配列（初期）
		tmpIdAry = Array.new

		# 中間XMLルート要素生成
		tmpDoc.add(Element.new("exam"))
		tmpDoc.elements["exam"].add_attribute("id", "userID") # 学習者ID?が入る予定

		# 出題順の取得（全体）
		ordering = get_examOrdering(inDoc)

		itmID = nil # アイテムid

		get_groups(inDoc).each{|grps|
			# 呼出し記述のgroup要素ごとに処理を行う
			grpID = get_grpID(grps) # 設定したidのグループを選択
			grpMark = get_grpMark(grps) # グループの配点

			#履歴保存（グループ）
			history.add_group(grpID, grpMark)
#puts "Group ID: " + grpID.to_s
			# 問題DBの問題群IDを指定
			t_db.create_doc(grpID.to_s)

			get_items(grpID, inDoc).each{|itms| # 一度出題リストを生成
#puts itms
				itmID = get_itmID(itms)
				itmType = get_itmType(itms)
				eAry << itmID
#puts itmType

				# idにより処理を分岐（random：ランダム, type：問題形式, その他：問題id）
				case itmType
					when "random" then
						# ランダム指定出題用配列
						tmpOHash["random"] = ""
						setOHash[itmID] = "random"
						setAry << "random"
					when "type" then
						# 現時点ではランダム
						# 形式指定出題用配列
						tmpOHash["type"]  = get_itemType(itms)
						setOHash[itmID] = "type"
						setAry << "type"
					else
						# id指定出題用配列
						tmpOHash["id"] = itmType
						setOHash[itmID] = "id"
						setAry << "id"
				end
			}

			# 確定したidを配列に格納（配列への格納順は考慮しない）
			# id指定
			tmpOHash['id'].each{|lis|
#puts "ID: " + lis.to_s
				tmpIdAry << lis
				itemOHash['id'] = lis 
			}
			# 形式指定
			tmpOHash['type'].each{|lis|
				tmpType = t_db.get_IDbyType(lis, tmpIdAry)
#puts "tmpType: " + tmpType.to_s
				tmpIdAry << tmpType
				itemOHash['type'] = tmpType
			}
			# ランダム指定
			tmpOHash['random'].each{|lis|
				tmpRandom = t_db.get_IDbyRand(tmpIdAry)
#puts "tmpRandom :" + tmpRandom
				tmpIdAry << tmpRandom
				itemOHash['random'] = tmpRandom
#p @t_db.get_IDbyRand(tmpIdAry)
			}

#print "tmpIdAry :"
#p tmpIdAry

			# tmpIdAry配列中に確定した全てのidが入る
			# このid群を元に実際に問題を出題
			# そのままitem要素をコピーではなく付加情報が必要？→グループIDやpassing_grade要素など
			# ハッシュ値内のリスト用カウンタ
			# 何回目の呼出しか
			cType = 0
			cRandom = 0
			cID = 0
			eCount = 0
			elem = Element.new
#p tmpOHash.keys
#p tmpOHash.values
#puts
#p itemOHash.keys
#p itemOHash.values
#p setAry
#p eAry

			# 出題順に従って出題と履歴を作成
			setAry.each{|sary|
			#setOHash.keys.each{|key|
#puts "setOHash key: " + key
				#setOHash[key].each{|val|
#puts "setOHash value: " + val
				case sary
					when "id" then
						sItem_id = itemOHash['id'][cID].to_s
#puts "ID: " + grpID.to_s + "_" + sItem_id
						elem =  t_db.get_itembyID(sItem_id)
						elem.add_attribute("id", grpID.to_s + "_" + sItem_id)
						elem.add_attribute("type", get_typeValue(get_itmType(elem).to_s))
						# 履歴保存（問題）
						history.add_item(grpID, grpID.to_s + "_" + sItem_id)
						history.add_info2item(grpID, grpID.to_s + "_" + sItem_id, get_pgrade(grpID, eAry[eCount], inDoc))
						itemAry << elem
						cID = cID + 1
					when "type" then
						if itemOHash['type'][cType] != false then
							sItem_id = itemOHash['type'][cType].to_s
#puts "Type: " + grpID.to_s + "_" + sItem_id
							elem =  t_db.get_itembyID(sItem_id)
							elem.add_attribute("id", grpID.to_s + "_" + sItem_id)
							elem.add_attribute("type", get_typeValue(get_itmType(elem).to_s))
							# 履歴保存（問題）
							history.add_item(grpID, grpID.to_s + "_" + sItem_id)
							history.add_info2item(grpID, grpID.to_s + "_" + sItem_id, get_pgrade(grpID, eAry[eCount], inDoc))
							itemAry << elem
							cType = cType + 1
						end
					when "random" then
						if itemOHash['random'][cRandom] != false then
							sItem_id = itemOHash['random'][cRandom].to_s
#puts "Random: " + grpID.to_s + "_" + sItem_id
							elem =  t_db.get_itembyID(sItem_id)
							elem.add_attribute("id", grpID.to_s + "_" + sItem_id)
							elem.add_attribute("type", get_typeValue(get_itmType(elem).to_s))
							# 履歴保存（問題）
							history.add_item(grpID, grpID.to_s + "_" + sItem_id)
							history.add_info2item(grpID, grpID.to_s + "_" + sItem_id, get_pgrade(grpID, eAry[eCount] ,inDoc))
							itemAry << elem
							cRandom = cRandom + 1
						end
				end
				#}
				eCount = eCount + 1
#puts elem
			}

# for Debug
#puts tmpIdAry.join(', ')
#p tmpOHash.keys
#p tmpOHash.values
#puts
#p itemOHash.keys
#p itemOHash.values
#puts
#p setOHash.keys
#p setOHash.values
#puts setAry.join(', ')
#puts

			tmpOHash.clear
			itemOHash.clear
			setAry.clear
			eAry.clear
			setOHash.clear
			tmpIdAry.clear
		}


		# 出題順がrandom指定ならランダマイズ
		if ordering == "random"  then
			itemAry = randArray(itemAry)
		end
#puts @history.printHistory
#puts itemAry.join(', ')
#p itemAry.join(', ')

		# 中間XMLの生成
		itemAry.each{|i|
			tmpDoc.elements["exam"].add_element(i)
		}
#puts @tmpDoc.to_s.kconv(Kconv::EUC, Kconv::UTF8)
#puts "tmpDoc"
#puts tmpDoc
#puts 
		# 出題ログ生成
		# make_history

		# xsltオブジェクト
		xslt = XML::XSLT.new()
		xslt.xml = tmpDoc
		x = REXML::Document.new File.open( "./test.xsl" )
		xslt.xsl = x
		out = xslt.serve() # Stringオブジェクト

		outDoc = REXML::Document.new(out)
		#puts @outDoc.class
#puts @outDoc
#puts @tmpDoc

		# 履歴を保存させる
		history.saveHistory("./func/history.xml")

		#puts @outDoc.get_elements("//body/node()")
		# body要素以下を返す
		return outDoc.get_elements("//body/node()")

		#return @outDoc
	end


	# examination要素以下のgroup要素の取得
	def get_groups(inDoc)
		return inDoc.get_elements("/examination/group")
	end


	# 出題順の取得（全体）
	def get_examOrdering(inDoc)
		return REXML::XPath.first(inDoc, "/examination").attributes["ordering"]
	end


	# group[@id=gID]以下のitem要素の取得
	def get_items(gID, inDoc)
		return inDoc.get_elements("/examination/group[@id = \"" + gID.to_s + "\"]/item")
	end


	# 指定したitem要素以下のselection_type要素のテキストノードの取得
	# 現時点の仕様では、id属性でrandomとtypeを一意に決定できないので、
	# コンテキストノード的なElements要素を引数に取る。
	def get_itemType(item_node)
		return item_node.text("selection_type")
	end


	# group（Element）要素の持つグループidを取得
	def get_grpID(grp)
		return grp.attributes["id"]
	end


	# group（Element）要素の持つグループの配点を取得
	def get_grpMark(grp)
		return grp.attributes["mark"].to_s
	end


	# item（Element）要素の持つtype属性を取得
	def get_itmType(itm)
		return itm.attributes["type"].to_s
	end


	# item（Element）要素の持つid属性を取得
	def get_itmID(itm)
		return itm.attributes["id"]
	end


	# 呼び出し記述からpassing_gradeの値を取得
	def get_pgrade(grpID, itmID, inDoc)
	#puts grpID
	#puts itmID
	#puts inDoc.get_elements("/examination/group[@id = \"" + grpID + "\"]/item[@id=\"" + itmID + "\"]/passing_grade")[0]
		return inDoc.get_elements("/examination/group[@id = \"" + grpID + "\"]/item[@id=\"" + itmID + "\"]/passing_grade")[0]
	end


	# 問題形式からinput要素のtype属性値を決める
	def get_typeValue(type)
		inpType = create_doc4itype

		typeAry = Array.new
		typeAry = inpType.get_elements("/input_type/input/object[@type=\"" + type + "\"]")
#puts type
#puts typeAry[0].parent.attribute("type")
		return typeAry[0].parent.attribute("type")
	end


	# input要素のtype属性値を記録したxml文書を読み込む
	def create_doc4itype
		inpType = nil
		File.open("./func/input_type.xml") {|fp|
		# 空白のみのテキストノードを無視
		inpType = REXML::Document.new(fp, {:ignore_whitespace_nodes => :all})
		}
		return inpType
	end
end