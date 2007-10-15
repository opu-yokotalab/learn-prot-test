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
require "cgi"
# ʸ���������Ѵ�
require "kconv"

require "./func/hhistory"

class Result

	# ���󥹥ȥ饯��
	def initialize
		# QueryString����
		qs = CGI.new
    		@params = qs.params
		#@params = {"q1" => "0", "q2" => "1", "q3" => "2"} # �ƥ�����
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
		str = "<?xml version='1.0' encoding='UTF-8'?><!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"><html lang='ja' xml:lang='ja' xmlns='http://www.w3.org/1999/xhtml'>  <head>    <meta content='application/xhtml+xml; charset=UTF-8' http-equiv='Content-Type'/>  <meta http-equiv=\"Pragma\" content=\"no-cache\" /> <meta http-equiv=\"Cache-Control\" content=\"no-cache\" />  <link href='test_m.css' rel='stylesheet' type='text/css'/>    <title>���ƥ��ȵ����ץ�ȥ����ע�</title>    <script type='text/javascript' src='./func/evaluate.js'><!--hoge--></script>  </head><body>\n"
		return str.kconv(Kconv::EUC, Kconv::UTF8)
		
	end

	# HTML�����ν񤭽Ф�
	def printHTMLFoot
		str = "</body></html>"
		return str.kconv(Kconv::EUC, Kconv::UTF8)
	end
	
end


rslt = Result.new
hh = Hhistory.new

hHash = Hash.new
str = ""

print "Content-type: text/html\n\n"
print rslt.printHTMLHead

hHash = hh.history_gets
#p hHash
hHash.each{|key, value|
	str = "���롼��" + key + "�������� " + value + " ��<br />"
	print Kconv.kconv(str, Kconv::UTF8)
}


print rslt.printHTMLFoot

# m_test.print_tree
#p m_test.get_numGroup
#p m_test.get_order("q1")
#p m_test.get_numItem("q1")
