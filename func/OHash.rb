#!/usr/bin/env ruby
#
# ■テスト機構プロトタイプ
# 入力順を保持するハッシュクラス

class OHash

	def initialize
		@keys = Array.new
		@content = Hash.new{|@content, key| @content[key] = [] }
	end

	def size
		@content.size
	end

	alias length size

	def [](key)
		@content[key]
	end

	def []=(key, value)
		@content[key] << value
		if !@keys.include?(key)
			@keys << key
		end
	end

	def delete(key)
		@key.delete(key)
		@content.delete(key)
	end

	def keys
		@keys.dup
	end

	def values
		@keys.map{|key| @content[key] }
	end

	def clear
		@keys.clear
		@content.clear
	end
end