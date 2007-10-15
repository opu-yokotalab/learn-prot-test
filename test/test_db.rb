#!/usr/bin/env ruby
#
# �ƥ����������ץ����(��)
# ver 0.0.1
# ������ 05/12/08
# �ǽ������� 05/12/29

  
# XML���
require "rexml/document"
# ʸ���������Ѵ�
require "kconv"
# �������
require "./test/value"
# ����
require "./test/history"

class Test_db
  
  # XML���
  include REXML
  # �������
  include Value
  
  # ���󥹥ȥ饯��
  def initialize
    # REXML::Document
    @doc = nil
    # ���귲id
    @problem_id
    # item���Ǥ�id
    @item_id = nil
    # ���򥯥饹
    @his_mod = History.new
    # ����
    @his = Hash.new
  end
  
  # �����ץ�
  def create_doc(filename)
    File.open(Value::DB_base + filename + ".xml") {|fp|
      # ����ΤߤΥƥ����ȥΡ��ɤ�̵��
      @doc = REXML::Document.new(fp, {:ignore_whitespace_nodes => :all})
      @problem_id = filename
    }
  end
  
  # ���ꤹ��item���Ǥ�id�򥻥å�
  def set_itemid(id)
    # ������random�ʤ����ǿ��ʲ������������
    if id == "random" then
      @item_id = rand(get_ElementsLength("//item")).to_s
      @his.store(@problem_id, @item_id)
      return @item_id
    end
    # id�����ꤵ��Ƥ����饻�å�
    @item_id = id
    @his.store(@problem_id, @item_id)
    return @item_id
  end 
  
  # prob���ǤλҥΡ��ɤμ���
  def get_prob()
    lis =  REXML::XPath.first(@doc,"//item[@id=\"" + @item_id + "\"]/prob/node()")
    return lis.to_s.kconv(Kconv::EUC, Kconv::UTF8)
  end
  
  # response���ǤλҥΡ��ɤμ���
  # out : Array
  def get_response()
    lis = REXML::XPath.match(@doc,"//item[@id=\"" + @item_id + "\"]/response/node()")
    # �ƥ����ȥΡ��ɤ�ʸ�������ɤ��Ѵ�������˳�Ǽ
    s_ary = Array.new
    count = 0
    lis.each {|i|
      s = i.to_s
      s_ary[count] =  s.kconv(Kconv::EUC, Kconv::UTF8)
      count = count + 1
    }
    return s_ary
    endget_history
  end
  
  # hints���ǤλҥΡ��ɤμ���
  def get_hints()
    lis =  REXML::XPath.first(@doc,"//item[@id=\"" + @item_id + "\"]/hints/node()")
    return lis.to_s.kconv(Kconv::EUC, Kconv::UTF8)
  end
  
  # correct���Ǥ�id°���ͤμ���
  # out : Array
  def get_correct()
    lis =  REXML::XPath.first(@doc,"//item[@id=\"" + @item_id + "\"]/correct")
    # °���ͤ�","��ʬ�䤷�����
    return lis.attributes["id"].split(",")
  end
  
  # explanation���ǤλҥΡ��ɤμ���
  def get_explanation()
    lis =  REXML::XPath.first(@doc,"//item[@id=\"" + @item_id + "\"]/explanation/node()")
    return lis.to_s.kconv(Kconv::EUC, Kconv::UTF8)
  end
  
  # ���ꤷ���Ρ��ɿ��Υ������
  def get_ElementsLength(path) 
    elems =  @doc.elements.to_a(path).collect
    return elems.length
  end
  
  # item���Ǥ�type°�����ͤ��������
  def get_itemtype()
    lis =  REXML::XPath.first(@doc,"//item[@id=\"" + @item_id + "\"]")
    return lis.attributes["type"]
  end
  
  # �������
  def put_history()
    @his_mod.his = @his
    @his_mod.history_puts
    #      p @his_mod.history_gets
  end
  
end
  

# �ư����
if __FILE__ == $0 then
  prot = Test_db.new
  prot.create_doc("q1")
  prot.set_itemid("random")
  puts prot.get_itemtype()
  puts prot.get_prob()
  puts prot.get_response()
  puts prot.get_hints()
  puts prot.get_correct()
  puts prot.get_explanation()
end
