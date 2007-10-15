#!/usr/bin/env ruby
#
# ���ƥ��ȵ����ץ�ȥ�����
# ver 0.0.1
# ������ 06/09/12
# �ǽ������� 06/09/12

# Document���֥������Ȥ����
# �ƥ��ȵ������Ǥ��ᡢ��礻��Ԥ��᥽�åɤ��ꤲ��
# �֤��ͤϴ�����������XHTML����������ͤ��ݻ��������饹�Υ��󥹥��󥹡�
# �֤��ͤ�ɽ������XHTML�ο����ȥޡ���


# QueryString����
#require "cgi"
# XML���
require "rexml/document"
# ʸ���������Ѵ�
require "kconv"
# �ƥ��ȵ������󥿥ե�����
require "./func/mod_test"


class Adel_exam

	# XML���
	include REXML
	# �������
	# include Value
	# �ƤӽФ����Ҳ�����礻

	# ���󥹥ȥ饯��
	def initialize
		# QueryString����
		#qs = CGI.new
    		#@params = qs.params
    		@params = Hash.new
		#@params = {"mode" => nil} # �ƥ����� #
		@params = {"mode" => "evaluate", "name" => "q1_3", "type" => "radio", "value" => "0"} # �ƥ�����
		# REXML::Document
		@doc = nil
	end

	# �����ץ�
	def create_doc()
		File.open("./examination_prot.xml") {|fp|
		# ����ΤߤΥƥ����ȥΡ��ɤ�̵��
		@doc = REXML::Document.new(fp, {:ignore_whitespace_nodes => :all})
		}
		lis = REXML::XPath.first(@doc,"//examination")
		return lis
	end

	# ư��⡼�ɤ��֤��ʽ��ν��ꡢ1�䤴�Ȥ�ɾ�����ʤɡ�
	def get_Mode
		return @params["mode"].to_s
	end

	# �����Υϥå�������
	def get_params
		return @params
	end

	# HTMLƬ���ν񤭽Ф�
	def printHTMLHead
		str = "<?xml version='1.0' encoding='UTF-8'?><!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"><html lang='ja' xml:lang='ja' xmlns='http://www.w3.org/1999/xhtml'>  <head>    <meta content='application/xhtml+xml; charset=UTF-8' http-equiv='Content-Type'/>  <meta http-equiv=\"Pragma\" content=\"no-cache\" /> <meta http-equiv=\"Cache-Control\" content=\"no-cache\" />  <link href='test_m.css' rel='stylesheet' type='text/css'/>    <title>���ƥ��ȵ����ץ�ȥ����ע�</title>    <script type='text/javascript' src='./func/evaluate.js'><!--hoge--></script>  </head><body>"
		return str.kconv(Kconv::EUC, Kconv::UTF8)
		
	end

	# HTML�����ν񤭽Ф�
	def printHTMLFoot
		str = "</body></html>"
		return str.kconv(Kconv::EUC, Kconv::UTF8)
	end
	
end


adel = Adel_exam.new
#print adel.create_doc()
#print "\n"
#print adel.create_doc().class
#print "\n"
#����⡼�ɤǥƥ��ȵ������󥹥�������
m_test = Mod_test.new(adel.get_params)
#m_test.set_examination(adel.create_doc())
p adel.get_params
case m_test.get_mode(adel.get_params)
	when "set" then # �ǽ�θƤӽФ�
		#print "Content-type: text/html\n\n"
		#print adel.printHTMLHead
		#print m_test.get_xhtmlAll(adel.create_doc())
		print m_test.get_xhtmlAll(adel.create_doc())
		#print adel.printHTMLFoot
	when "pre_evaluate" then # �ץ�ɾ��
		#print "Content-type: text/html\n\n"
		print "<e_result>"
		print m_test.pre_evaluate(adel.get_params)
		print "</e_result>"
	when "evaluate" then # ��������
		print "Content-type: text/html\n\n"
		print m_test.evaluate(adel.get_params)
		p m_test.grp_evaluate
end

# m_test.print_tree
#p m_test.get_numGroup
#p m_test.get_order("q1")
#p m_test.get_numItem("q1")
