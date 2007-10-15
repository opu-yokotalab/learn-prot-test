#!/usr/bin/env ruby
#
# ■テスト機構 プロトタイプ
# ver 0.0.1
# 作成日 06/09/12
# 最終更新日 06/09/12

# mode:
# 	set:出題
#	evaluate:解答

# XML操作
require "rexml/document"
# Ruby-xslt （要インストール）
require 'xml/xslt'
# 文字コード変換
require "kconv"
# 出題用モジュール
require "./func/set_problem"
# 評価用モジュール
require "./func/evaluate"
# 問題DBアクセス用
require "./func/test_db"
# 入力順を保持するハッシュクラス
require "./func/OHash"
# 出題ログ用モジュール
require "./func/history"

class Mod_test

	# XML操作
	include REXML
	# 出題モジュール
	include Set_problem
	# 評価モジュール
	include Evaluate
	# 入力順を保持するハッシュクラス
	#include OHash

	# 動作モード
	@mode = nil

	def initialize(att_mode)
		#init_setProblem()
	end

	# GETメソッドの引数を受け取る
#	def set_params(params)
		
#	end

	# テスト機構の動作モード（出題 or 評価）
	def get_mode(params)
		case params["mode"].to_s
			when "" then # 最初の出題
				@mode = "set"
			when "set" then # 最初の出題
				@mode = "set"
			when "pre_evaluate" then # 部分的な評価（選択肢ごと）
				@mode = "pre_evaluate"
			when "evaluate" then # 解答の確定
				@mode = "evaluate"
			when "result" then # 結果の出力
				@mode = "result"
			else # 何も該当しない
				return false # 呼び出しが誤っている
		end
		return @mode
	end

	# 問題記述の抽出
	def get_src(params)
		case params["src"].to_s
			when "" then # 記述なし
				return false # エラー
			else
				return params["src"].to_s
		end
	end

end
