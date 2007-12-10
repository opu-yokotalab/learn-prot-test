#!/bin/env ruby
#
# ����⥸�塼��
#

# HTTP�̿�
require "net/http"

# REXML
require "rexml/document"

# Ruby-XSLT
require "xml/xslt"

# ʸ���������Ѵ�
require "kconv"

# MD5�η׻���
require "digest/md5"


class Set_question

  include REXML

  # �����
  def initialize(user_id)
    # �ƥ��Ⱦ���
    @test_id = String.new

    # �桼��id
    @user_id = user_id
  end

    # ¿��������ˤ�����ơ��֥�
  # [{���롼��id, ����, ����id, ���꥿����, ɾ�������, ����ե��륿, ���꥿����, ��ͭ���̻�}, ...]
#    @setTable = make_table(input_xml)

    # ��������λ��������ơ��֥�
 #   return @setTable

  
  # �ƽФ����Ҥ������ν����ѥơ��֥���Ѵ�
  def make_table(input_xml, base_eXist_host, base_eXist_port, base_db_uri)
    # Document���֥������Ȥ�����
    #tmpDoc = REXML::Document.new(input_xml)
    tmpDoc = input_xml
#puts tmpDoc
    # �ƤӽФ����Ҥ��������������ߤ���
    if tmpDoc.elements["//examination"] == nil then
#puts "Error"
      return -1
    end
    
    # �ơ��֥�ι�
    setAry = Array.new
    
    # �ƥ���id�μ���
    @test_id = tmpDoc.elements["//examination"].attributes["id"]


    # ��Ͽ����
    setTime = Date.today.to_s + " " + Time.now.strftime("%X")
  
    
    # �ƥ��롼��ñ�̤θƽФ��ˤĤ���
    tmpDoc.get_elements("//examination/group").each{|tmpElem|
      grpAttr = tmpElem.attributes
      # ���롼��id�μ���
      group_id = grpAttr["id"]
      # �����μ���
      mark = grpAttr["mark"]
      
      # ���롼����γ�����θƽФ��ˤĤ���
      tmpElem.get_elements("item").each{|tmpItm|
        itmAttr = tmpItm.attributes
        # ����id�μ���
        #item_id = itmAttr["id"]
        item_id = ""
        # ��������μ���
        item_type = itmAttr["type"]
        if item_type != "random" and item_type != "type" then
          item_id = item_type
        end
        
        # ɾ�������
        tmpOpt =  tmpItm.elements["passing_grade"]
        if tmpOpt != nil then
          ques_pass =  tmpOpt.get_text.to_s
        else
          ques_pass = ""
        end
        
        # �������
        tmpOpt =  tmpItm.elements["selection_type"]
        if tmpOpt != nil then
          # idľ�ܻ���ʳ�����������ξ�硢�����ǽ��ꤹ����������
          ques_type = tmpOpt.get_text.to_s
        else
          ques_type = ""
        end
        
        # ���ν���(����?)������θ���뤫
        tmpOpt =  tmpItm.elements["selection_correct"]
        if tmpOpt != nil then
          ques_correct = tmpOpt.get_text.to_s
        else
          ques_correct = ""
        end

        # ��ͭ���̻�(pkey)������
        pkeyInt = Time.now.tv_sec + rand(1000000)
        pkey = Digest::MD5.new(pkeyInt.to_s).to_s
#puts "make_table: " + pkey        
         # �ϥå��������˳�Ǽ
        setAry << {"group_id" => group_id, "mark" => mark, "item_id" => item_id, "ques_pass" => ques_pass,"ques_type" => item_type , "selection_type" => ques_type, "ques_correct" => ques_correct, "time" => setTime, "test_key" => pkey}

        # ɬ�פ�ʬ���������
        item_id = ""
        ques_pass = ""
        item_type = ""
        ques_type = ""
        ques_correct = ""
      }
    }
    # ̤������������ꤵ����
    setAry = set_table(setAry, base_eXist_host, base_eXist_port, base_db_uri)

    # ���XML���Ѵ�
    #make_xml(setAry)
    
    # �ơ��֥���֤�
    return setAry
  end

  # ����ơ��֥�����������[random,type]�ˤĤ�������id����ꤵ����
  def set_table(tbl, base_eXist_host, base_eXist_port, base_db_uri)
    # ���˳���ѤߤΥ��롼��id������id�����
    # {"group_id" => [item_id, ...]}
    tmpSetList = Hash.new{|h, key| h[key] = []}
    
    tbl.each{|tblLine|
      if tblLine["ques_type"] != "random" and tblLine["ques_type"] != "type" then
        tmpSetList[tblLine["group_id"]] << tblLine["ques_type"]
      end
    }

    # ����ơ��֥����Ƭͥ��ǽ�˽��ꤹ����������
    tmpItemId = ""
    tbl.each_with_index{|tblLine, idx|
      if tblLine["ques_type"] == "random" then
        # ���������
        tmpItemId = get_itemId(tblLine["group_id"], "", tmpSetList[tblLine["group_id"]], "random", base_eXist_host, base_eXist_port, base_db_uri)
        
        # ���ޤ������Ǥ��Ƥ���褦���ä���ơ��֥���������ؤ�
        if tmpItemId != "" then
          tmpSetList[tblLine["group_id"]] << tmpItemId
          tbl[idx]["item_id"] = tmpItemId
        end
        
      elsif tblLine["ques_type"] == "type" then
        # �����������
        tmpItemId  << get_itemId(tblLine["group_id"], tblLine["selection_type"], tmpSetList[tblLine["group_id"]], "type", base_eXist_host, base_eXist_port, base_db_uri)
        
        # ���ޤ������Ǥ��Ƥ���褦���ä���ơ��֥���������ؤ�
        if tmpItemId != "" then
          tmpSetList[tblLine["group_id"]] << tmpItemId
          tbl[idx]["item_id"] = tmpItemId
        end
      end      
    }
    
    #p tmpSetList
    #p tbl

    # �񤭴���������ơ��֥���֤�
    return tbl
  end
  
 # ����ơ��֥뤫�����XML������
  def make_xml(tbl, base_eXist_host, base_eXist_port, base_db_uri, base_inputType_uri)
    # ǰ�Τ���桼��id�Υ����å�
    if @user_id == "" then
      return -1
    end

    # �롼�ȥΡ��ɤκ���
    tmpRoot = REXML::Element.new("exam")
    tmpRoot.add_attribute("user_id", @user_id )
    
    # ���ǣ��Ĥ��Ľ����򤷤Ƥ���
    tmpElem = REXML::Element.new
    tbl.each{|tblLine|
      tmpElem = get_item(tblLine["group_id"], tblLine["item_id"], base_eXist_host, base_eXist_port, base_db_uri)

      # ���°����(item_id)�������ơ��Ѵ��Ѥ�id(group_id + "_" + item_id)�������
      tmpElem.delete_attribute("id")
      tmpElem.add_attribute("id", tblLine["group_id"] + "_" + tblLine["item_id"] )

      # �Ĥ��Ǥ�xhtml��input���Ǥ�type°���ͤ����
      tmpType = tmpElem.attributes["type"]
      tmpElem.delete_attribute("type")
      tmpElem.add_attribute("type", convInputType(tmpType, base_eXist_host, base_eXist_port, base_inputType_uri))
#puts "make_xml: " + tblLine["test_key"]
      # ��ͭ���̻Ҥ��ɲ�
      tmpElem.add_attribute("ques_pkey", tblLine["test_key"])
      
      # �롼�ȥΡ��ɤ��ɲ�
      tmpRoot.add_element(tmpElem)
    }

    return tmpRoot
  end
  
  # XHTML�ե����������
  def make_xhtml(input_xml, base_eXist_host, base_eXist_port, base_xslt_uri)  
        
    # xslt���֥�������
    xslt = XML::XSLT.new()
    xslt.xml = input_xml.to_s

    # XSLT�������륷���Ȥ�XML�ǡ����١���������äƤ���
    http = Net::HTTP.new(base_eXist_host, base_eXist_port)
    req = Net::HTTP::Get.new(base_xslt_uri)
    res = http.request(req)
   
    xslt_doc = REXML::Document.new(res.body)
    
    xslt.xsl = xslt_doc
    out_xml = xslt.serve() # String���֥�������
    
    outDoc = REXML::Document.new(out_xml)
    return outDoc
    #puts @outDoc.class
    #puts @outDoc
    #puts @tmpDoc   
  end

  # ���롼��id������id���鳺���������국�Ҥ����
  def get_item(group_id, item_id, base_eXist_host, base_eXist_port, base_db_uri)
#    p group_id
#    p item_id

    # Web�����Ф���ɥ�����Ȥ����
    http = Net::HTTP.new(base_eXist_host, base_eXist_port)
    req = Net::HTTP::Get.new(base_db_uri + group_id + ".xml?_query=//problem_set/item[@id=%22" + item_id  + "%22]")
    res = http.request(req)

    docElem = REXML::Document.new(res.body)
    elem = docElem.elements["//item"]
# p elem   
    return elem
  end
  
  # ����Ū�ʻ���ʳ��ν�����ˡ�ǽ����ǽ������id���֤�
  def get_itemId(group_id, item_type, itemList, mode, base_eXist_host, base_eXist_port, base_db_uri)

    # ������ˡ����³���ѹ�
    if mode == "type" then
      reqStr = base_db_uri + group_id + ".xml?_query=//problem_set/item[@type=%22" + item_type  + "%22]"
      elsif mode == "random" then
      reqStr = base_db_uri + group_id + ".xml?_query=//problem_set/item"
    end    

    # Web�����Ф���ɥ�����Ȥ����
    http = Net::HTTP.new(base_eXist_host, base_eXist_port)
    req = Net::HTTP::Get.new(reqStr)
    res = http.request(req)

    # Document���֥������Ȥ�����
    doc = REXML::Document.new(res.body)

    # ���ꤵ�줿�������������
    tmpElem = doc.get_elements("//item")

    # �����Ρ��ɤ����뵤��
    if tmpElem.size != 0 then

      settableList = Array.new
      # �����ǽ������id�����
      tmpElem.each{|elemLine|
        settableList << elemLine.attributes["id"].to_s
      }

      # �����ǽ�������׻����ʤ��ä��齪λ
      tmpList = settableList - itemList
      if tmpList.length == 0 then
        # �����ǽ������ʤ�
        return -1
      end

      tmpSize = tmpList.length # ����������    

      # ��󤵤줿���꤫��Ŭ��������id������
      rndIndex = tmpList[rand(tmpSize)]

      return rndIndex
    end

    # �����Ρ���̵��
    return -1
  end

  # �ƥ���id���֤�
  def get_testId
    return @test_id
  end
  
  # ���국����������������������������
  def convInputType(type, base_eXist_host, base_eXist_port, base_inputType_uri)
    # Web�����Ф���ɥ�����Ȥ����
    http = Net::HTTP.new(base_eXist_host, base_eXist_port)
    req = Net::HTTP::Get.new(base_inputType_uri)
    res = http.request(req)
    
    docElem = REXML::Document.new(res.body)

    # ��������type°���ͤ���ĥΡ��ɤ�õ��
    srchElem = docElem.get_elements("/input_type/input/object[@type=\"" + type + "\"]")

    # ���ΥΡ��ɤοƤ�type°���ͤ��֤�
    return srchElem[0].parent.attributes["type"].to_s
    
  end
  
  # �ơ��֥�������Ǥ򥷥�åե�
  def randomize(tbl)
    tbl.sort_by{rand}
    return tbl
  end
end

# ñ�ΤǤ�ư���ǧ
if __FILE__ == $0 then    
  # Web�����Ф���ɥ�����Ȥ����
  http = Net::HTTP.new('localhost', 8080)
  req = Net::HTTP::Get.new("/exist/rest//db/home/learn/examination/examination_prot.xml")
#  req = Net::HTTP::Get.new("/exist/rest//db/home/learn/examination/saiki_examin.xml")
  res = http.request(req)
  
  #puts Kconv.kconv(res.body, Kconv::EUC)
  
  # DOM���֥������Ȥ��Ѵ�
  tmpDoc = REXML::Document.new(res.body)

#puts tmpDoc
  
  setQues = Set_question.new()

  # �ƤӽФ����Ҥ������ơ��֥������
  setTable = Array.new
  setTable = setQues.make_table(tmpDoc)

  # ����ơ��֥뤫�����XML������
  setElem = REXML::Element.new
  setElem = setQues.make_xml(setTable)
#puts setElem

  # ���XML��XSLT���Ѥ���XHTML���Ѵ�
  xhtmlElem = REXML::Element.new
  xhtmlElem = setQues.make_xhtml(setElem)

  puts xhtmlElem
end
