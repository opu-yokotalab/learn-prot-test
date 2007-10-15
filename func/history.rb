#!/usr/bin/env ruby
#
# 履歴クラス

# XML操作
require "rexml/document"
# 文字コード変換
require "kconv"
# 中間XML操作モジュール
require "./func/set_history"

class History

	include REXML
	include Set_history

	# クラス変数
	@His = nil # ログのDocumentオブジェクト
	#@exam_log = nil # 学習者ID単位のログ用Elementオブジェクト
	#@uid = nil # 学習者ID

	# コンストラクタ
	def initialize(t_id, mode)
	# 履歴が存在していたらそれを読み込む。無ければ新規作成。
#puts "mode: " + mode
		if File.exist?("./func/history.xml") then
			if mode == "get" then
				@His = create_doc("./func/history.xml")
			elsif mode == "put" then
				# ルート要素新規作成
				create_root(t_id) # 作成
			end
		else
			create_root(t_id) #ルート要素作成
		end
	end

	# 履歴の読込み
	def create_doc(filename)
		doc = nil
		File.open(filename) {|fp|
		# 空白のみのテキストノードを無視
		doc = REXML::Document.new(fp, {:ignore_whitespace_nodes => :all})
		}
		return doc
	end

	# ルート要素の作成
	def create_root(t_id)
		@His = Document.new()
		@His.add(Element.new("exam"))
		@His.elements["exam"].add_attribute("id", t_id)
	end

	# グループの履歴追加
	def add_group(grpID, grpMark)
		@His = add_grp(grpID,grpMark, @His)
		return @His
	end

	# 問題の履歴追加
	def add_item(grpID, itmID)
		@His = add_itm(grpID, itmID, @His)
		return @His
	end

	# 問題の履歴に付加情報を記録
	def add_info2item(grpID, itmID, elem)
		@His = add_inf2item(grpID, itmID, elem, @His)
		return @His
	end

	# item要素のscore属性（評価結果），check属性（正解、不正解のフラグ）を付加
	def add_evaluated(grpID, itmID, score, checked)
		return add_evaluated_(grpID, itmID, score, checked ,@His)
	end

	# evaluate要素の削除
	def del_evaluate(grpID, itmID)
		delete_evaluate(grpID, itmID, @His)
	end

	# ログから評価したスコアを取得
	def get_score(grpID, itmID)
		return get_score_(grpID, itmID, @His)
	end

	# item要素を取る
	def get_items(grpID)
		return get_items_(grpID, @His)
	end

	# group要素をとる
	def get_groups()
		return get_groups_(@His)
	end

	# 履歴の保存
	def saveHistory(filename)
		save(filename, @His)
	end

	# 履歴の表示（for Debug）
	def printHistory
		puts @His
	end

end


# 動作試験
if __FILE__ == $0 then
  prot = History.new
  prot.his = {"q1" => "0", "q2" => "1", "q3" => "2"}
  prot.history_puts
#  print prot.hash2record + "\n"
#  p prot.record2hash("q1:2,q2:0,q3:1,")
#  print "\n"

#  p prot.history_gets
end
