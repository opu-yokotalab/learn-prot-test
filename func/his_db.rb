#!/bin/env ruby
#
# ����DB���饹�ʲ���
#

# XML���
require "rexml/document"
# ʸ���������Ѵ�
require "kconv"

class His_db

	include REXML

	def initialize
		@doc = nil
	end

	# Document���֥������Ȥ�����
	def create_doc(filename)
		File.open("./db/" + filename + ".xml") {|fp|
			# ����ΤߤΥƥ����ȥΡ��ɤ�̵��
			@doc = REXML::Document.new(fp, {:ignore_whitespace_nodes => :all})
		}
	end

end







