#!/bin/env ruby
#
# 履歴DBクラス（仮）
#

# XML操作
require "rexml/document"
# 文字コード変換
require "kconv"

class His_db

	include REXML

	def initialize
		@doc = nil
	end

	# Documentオブジェクトの生成
	def create_doc(filename)
		File.open("./db/" + filename + ".xml") {|fp|
			# 空白のみのテキストノードを無視
			@doc = REXML::Document.new(fp, {:ignore_whitespace_nodes => :all})
		}
	end

end







