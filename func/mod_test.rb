#!/usr/bin/env ruby
#
# ���ƥ��ȵ��� �ץ�ȥ�����
# ver 0.0.1
# ������ 06/09/12
# �ǽ������� 06/09/12

# mode:
# 	set:����
#	evaluate:����

# XML���
require "rexml/document"
# Ruby-xslt ���ץ��󥹥ȡ����
require 'xml/xslt'
# ʸ���������Ѵ�
require "kconv"
# �����ѥ⥸�塼��
require "./func/set_problem"
# ɾ���ѥ⥸�塼��
require "./func/evaluate"
# ����DB����������
require "./func/test_db"
# ���Ͻ���ݻ�����ϥå��奯�饹
require "./func/OHash"
# ������ѥ⥸�塼��
require "./func/history"

class Mod_test

	# XML���
	include REXML
	# ����⥸�塼��
	include Set_problem
	# ɾ���⥸�塼��
	include Evaluate
	# ���Ͻ���ݻ�����ϥå��奯�饹
	#include OHash

	# ư��⡼��
	@mode = nil

	def initialize(att_mode)
		#init_setProblem()
	end

	# GET�᥽�åɤΰ�����������
#	def set_params(params)
		
#	end

	# �ƥ��ȵ�����ư��⡼�ɡʽ��� or ɾ����
	def get_mode(params)
		case params["mode"].to_s
			when "" then # �ǽ�ν���
				@mode = "set"
			when "set" then # �ǽ�ν���
				@mode = "set"
			when "pre_evaluate" then # ��ʬŪ��ɾ��������褴�ȡ�
				@mode = "pre_evaluate"
			when "evaluate" then # �����γ���
				@mode = "evaluate"
			when "result" then # ��̤ν���
				@mode = "result"
			else # ���⳺�����ʤ�
				return false # �ƤӽФ�����äƤ���
		end
		return @mode
	end

	# ���국�Ҥ����
	def get_src(params)
		case params["src"].to_s
			when "" then # ���Ҥʤ�
				return false # ���顼
			else
				return params["src"].to_s
		end
	end

end
