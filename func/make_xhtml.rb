#!/usr/bin/env ruby
#
# ���ƥ��ȵ����ץ�ȥ�����
# xhtml����������
# ������ 06/09/12
# �ǽ������� 06/09/12

require "amrita2/template"
include Amrita2
# XML���
require "rexml/document"
include REXML
# ʸ���������Ѵ�
require "kconv"

class PO
  def title
    "hello world"
  end

  def body
    "Amrita2 is a html template libraly for Ruby"
  end
end
lis = nil
tmpl = TemplateFile.new("template.html")
#tmpl.expand(STDOUT, PO.new)
tmpl.expand(lis="", PO.new)
lis = lis.toutf8
# print lis.toutf8
# p lis.class

#src = REXML::SourceFactory.create_from(lis.toutf8)
#p src
e = REXML::Document.new(lis, {:ignore_whitespace_nodes => :all})
puts REXML::XPath.first(e,"//h1/text()")
