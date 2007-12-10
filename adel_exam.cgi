#!/bin/env ruby
#
# �ƥ��ȵ������󥿥ե�����
#

## -- �ɲå⥸�塼������ --

# CGI
require "cgi"

# HTTP�̿�
require "net/http"

# REXML
require "rexml/document"

# Ruby-XSLT
#require "xml/xslt"

# ʸ���������Ѵ�
require "kconv"

# MD5�η׻���
require "digest/md5"

# ����⥸�塼��
require "./func/history"

# ����⥸�塼��
require "./func/set_questions" 

# ɾ���⥸�塼��
require "./func/evaluate"


## -- include --

# XML�����
include REXML


## -- �Ķ��ѿ� --

# eXist, postgreSQL����³��Υۥ���
base_eXist_host = 'localhost'
# eXist����³�ݡ���
base_eXist_port = 8080

# postgreSQL��Ϣ
# eXist, postgreSQL����³��Υۥ���
base_pgsql_host = 'localhost'
# postgreSQL����³�ݡ���
base_pgsql_port = 5432
# �桼��̾
pgsql_user_name = "postgres"
# �ѥ����
pgsql_user_passwd = "postnamabu"

# ����DB
base_db_uri = "/exist/rest//db/home/learn/examination/db/"

# XSLT�������륷����
base_xslt_all_uri = "/exist/rest//db/home/learn/examination/test.xsl"
base_xslt_eval_uri = "/exist/rest//db/home/learn/examination/evaluate.xsl"

# XHTML�Ѵ����������������input���Ǥ�type°����
# ����ꤹ�뤿����Ѵ��ơ��֥�
base_inputType_uri = "/exist/rest//db/home/learn/examination/input_type.xml"


# �ʲ��ƥ����� 
# �ƤӽФ�����
#base_call_uri = "/exist/rest//db/home/learn/examination/examination_prot.xml" 
base_call_uri = "/exist/rest//db/home/learn/examination/saiki_examin.xml"

# ���顼����ɽ������xhtml
base_err_uri = "/exist/rest//db/home/learn/examination/error.xml"


## -- �ܽ��� --

# CGI�ΰ�����Ϣ
qs = CGI.new
params = qs.params

## ư��⡼��
## ���ꡢ�ץ�ɾ�����������ꡢ�ƥ������Τ�ɾ��

#params = {"user_id" => "uid", "mode" => "set"}
#params = {"mode" => "pre_evaluate"}
#params = {"mode" => "evaluate"}
#params = {"mode" => "result"}
#params = {"mode" => "get_testkey"}

# ư��⡼���̤˿���ʬ��
case params["mode"].to_s
when "set" then # ����  
  # Web�����Ф���ɥ�����Ȥ����
  http = Net::HTTP.new(base_eXist_host, base_eXist_port)
  req = Net::HTTP::Get.new(base_call_uri)

  res = http.request(req)

  # ���ߡ��θƤӽФ�����
  params["src"] = res.body

  ## �ܽ���  
  # DOM���֥������Ȥ��Ѵ�
  tmpDoc = REXML::Document.new(params["src"].to_s)

  # �桼��id����
  user_id = params["user_id"].to_s
  # �桼��id����ꤷ�ơ����굡���Υ��󥹥��󥹤�����
  setQues = Set_question.new(user_id)
  
  # �ƤӽФ����Ҥ������ơ��֥������
  setTable = Array.new
  setTable = setQues.make_table(tmpDoc, base_eXist_host, base_eXist_port, base_db_uri)

  # ����ơ��֥뤫�������������
  # �ƥ��Ȥθ�ͭ���̻Ҥ����
  setHis = History.new
  
  # ����DB����³
  conn = setHis.open_setHistory(base_pgsql_host, base_pgsql_port, pgsql_user_name, pgsql_user_passwd)
  
  # �ơ��֥�����Ǥ��Ȥ˽���
  setTable.each{|tblLine|    
    # 1�饤�󤺤������Ͽ    
    setHis.put_setHistory(user_id, setQues.get_testId, tblLine, conn)
  }

  # ����DB��������
  setHis.close_setHistory(conn)

  # ����ơ��֥뤫�����XML������
  setElem = REXML::Element.new
  setElem = setQues.make_xml(setTable, base_eXist_host, base_eXist_port, base_db_uri, base_inputType_uri)
  
  # ���XML��XSLT���Ѥ���XHTML���Ѵ�
  xhtmlElem = REXML::Element.new
  xhtmlElem = setQues.make_xhtml(setElem, base_eXist_host, base_eXist_port, base_xslt_all_uri)

  # �֥饦����ɽ�������뤿��Τ��ޤ��ʤ�
  print "Content-type: text/html\n\n"
  print xhtmlElem

when "pre_evaluate" then # �ץ�ɾ��
  ## ���ߡ�����
  # ������ä�������������
  #params["selected"] = "q4_0_0" # ����
  #params["selected"] = "q4_0_1" # ������
  
  #params["type"] = "radio" # ñ����������
  #params["type"] = "checked" # ʣ������
  #params["value"] = "value" # �ƥ���������

  #params["value"] = "0" # ����������
  #params["value"] = "1"
  #params["value"] = "2"

  # ����ƥ��Ȥǽ��ꤵ�줿����θ�ͭ���̻�
  #params["ques_pkey"] = "f2ad3984f7e59f93863af5bf577303bb"


  ## �ܽ���
  # ɾ���⥸�塼��Υ��󥹥�������
  evalQues = Evaluate.new
  
  # ɾ����̳�Ǽ�ѤΥϥå���
  evalResultHash = Hash.new
  
  # ����ơ��֥뤫�������������
  # �ƥ��Ȥθ�ͭ���̻Ҥ����
  # ����⥸�塼��Υ��󥹥��󥹺���
  setHis = History.new

  # ����DB����³
  conn = setHis.open_setHistory(base_pgsql_host, base_pgsql_port, pgsql_user_name, pgsql_user_passwd)
  
  # ��������
  setHisHash = Hash.new
  setHisHash = setHis.get_setHistory(params["ques_pkey"].to_s, conn)
  
  # �ץ�ɾ��
  evalResultHash = evalQues.preEvaluate(params["type"].to_s, params["ques_pkey"].to_s, params["value"].to_s, setHisHash)
#p evalResultHash
  # ɾ�������Ͽ
  setHis.put_preEvalHistory(params["ques_pkey"].to_s, evalResultHash, conn)
  
  # ����DB��������
  setHis.close_setHistory(conn)

  # �֥饦����ɽ�������뤿��Τ��ޤ��ʤ�
  print "Content-type: text/html\n\n"
  print "<e_result>" + evalResultHash["eval_result"]  + "</e_result>"
  
when "evaluate" then # �ƥ��Ȥ�ɾ��
  # �ץ�ɾ���������ϽФ��Ƥ�ΤǤޤȤ������ĤʤϤ�
  # ques_pkey�ȳƥ��롼��id������id�ǰ��ֿ�����ʪ���������
  # �����������xhtml���֤��ơ�ɾ�������comp_eval��true�ˤ���

  # ���ߡ�
  #params["ques_pkey"] = "7529c20403cba45d9f5caa751a6af921"
  #params["name"] = "q4_0"
  
  # ����⥸�塼��Υ��󥹥��󥹤����
  evalHis = History.new

  # ����̵���ǽ��굡���Υ��󥹥��󥹤�����(����Ϻ��ʤ�)
  setQues = Set_question.new("eval_mode")

  # �����Ǽ�ѤΥϥå���
  setHisHash = Hash.new
  evalHisHash = Hash.new
  
  # ����DB����³
  conn = evalHis.open_setHistory(base_pgsql_host, base_pgsql_port, pgsql_user_name, pgsql_user_passwd)

  # ɾ���⥸�塼��Υ��󥹥�������
  # ���������ɾ���������פ�ʤ���
  evalQues = Evaluate.new

  # ques_pkey����ץ�ɾ����������
  evalHisHash = evalHis.get_preEvalHistory(params["ques_pkey"].to_s, conn)

  # ��������̵���ä����
  # ̤�����ޡ������դ��Ʋ������˵�Ͽ?
#p evalHisHash.size
  if evalHisHash.size == 0 then
    # ��������
    setHisHash = Hash.new
    setHisHash = evalHis.get_setHistory(params["ques_pkey"].to_s, conn)
#p setHisHash
    # ̤�����ξ��ˡ�̤�����Υ���Ĥ���
    evalResultHash = Hash.new
    evalResultHash = evalQues.preEvaluate("radio", "NULL", "NULL", setHisHash)
#p evalResultHash
    # ɾ�������Ͽ
    evalHis.put_preEvalHistory(params["ques_pkey"].to_s, evalResultHash, conn)
  end

  # ���ꤷ�������˥ޡ�����Ĥ���
  evalHis.put_evalHistory(evalHisHash["evaluate_pkey"].to_s, conn)
  
  # ɾ����̤˱�����xhtml������
  # ques_pkey���������������
  setHisHash = evalHis.get_setHistory(params["ques_pkey"].to_s, conn)
  
  # ����DB��������
  evalHis.close_setHistory(conn)

  # �������򤫤�ʰ�Ū�ʽ���ơ��֥�����
  tblAry = Array.new
  tmpSetHash = {"group_id" => setHisHash["group_id"], "mark" => setHisHash["group_mark"], "item_id" => setHisHash["ques_id"], "ques_pass" => setHisHash["ques_pass"],"ques_type" => setHisHash["ques_id"] , "selection_type" => "", "ques_correct" => "", "time" => "", "test_key" => ""}
  tblAry << tmpSetHash
  
  # ����ơ��֥뤫�����xml�����
  setElem = REXML::Element.new
  setElem = setQues.make_xml(tblAry, base_eXist_host, base_eXist_port, base_db_uri, base_inputType_uri)

  # ɬ�פ���ʬ�ڤ���Ф�xhtml������
  xhtmlElem = REXML::Element.new
#puts setElem
  xhtmlElem = setQues.make_xhtml(setElem.elements["//item"], base_eXist_host, base_eXist_port, base_xslt_eval_uri)

  # �󼨤�ɬ�פʾ�����դ��ä���
  if evalHisHash["eval_result"] != "0" then
    xhtmlElem.elements["/div/div/h2"].add_text(Kconv.kconv("����!", Kconv::UTF8))
  else
    xhtmlElem.elements["/div/div/h2"].add_text(Kconv.kconv("������...", Kconv::UTF8))
  end

  
  # �֥饦����ɽ�������뤿��Τ��ޤ��ʤ�
  print "Content-type: text/html\n\n"
  print xhtmlElem

when "result" then # �ƥ������Τ�ɾ����̽���
  # ����������ɾ����̤��Ϥ�
  # {"group_id" => ����(����*����Ψ), ...}
  # ����Ψ = ���롼��ñ�̤ǳ�����������/���롼�פ�����ꤵ�줿�����������

  #params["test_key"] = "6a0027335cdc26cbd4a0ec5f13c0f4b7"
  
  # ����⥸�塼��Υ��󥹥��󥹤����
  evalHis = History.new

  # ɾ���⥸�塼��Υ��󥹥��󥹤�����
  evalQues = Evaluate.new

  # �����Ǽ�ѤΥϥå���
  evalHisHash = Hash.new
  
  # ����DB����³
  conn = evalHis.open_setHistory(base_pgsql_host, base_pgsql_port, pgsql_user_name, pgsql_user_passwd)

  # �ƥ������Τ�ɾ����ɬ�פʾ�������
  tblEval = evalHis.get_evalHistory(params["test_key"].to_s, conn)
#p tblEval  

  # ɾ����̤�̤ɾ����ʬ������
  reEvalFlag = 0 # ��ɾ���Υե饰
  tblEval.each{|tblLine|
    if tblLine["eval_result"] == "" then
      # ̤�������֤ǥץ�ɾ��
      # ��������
      setHisHash = Hash.new
      setHisHash = evalHis.get_setHistory(tblLine["eval_key"].to_s, conn)
#p setHisHash
      # ̤�����ξ��ˡ�̤�����Υ���Ĥ���
      evalResultHash = Hash.new
      evalResultHash = evalQues.preEvaluate("radio", "NULL", "NULL", setHisHash)
#p evalResultHash
      # ɾ�������Ͽ
      evalHis.put_preEvalHistory(tblLine["eval_key"].to_s, evalResultHash, conn)      

      # ques_pkey����ץ�ɾ����������
      evalHisHash = evalHis.get_preEvalHistory(tblLine["eval_key"].to_s, conn)

      # ���ꤷ�������˥ޡ�����Ĥ���
      evalHis.put_evalHistory(evalHisHash["evaluate_pkey"].to_s, conn)

      # ��ɾ����Ԥ�
      reEvalFlag = 1
    end
  }

  if reEvalFlag == 1 then # ��ɾ����ɬ��
    # ���٥ƥ������Τ�ɾ����ɬ�פʾ�������
    tblEval = evalHis.get_evalHistory(params["test_key"].to_s, conn)
#p tblEval
    # �ե饰�ν����
    reEvalFlag = 0
  end

  # ����DB��������
  evalHis.close_setHistory(conn)

  # ɾ����̤�������
  normHash = Hash.new
  normHash = evalQues.evaluate(tblEval)

  # �ϥå��������Ϥ�����η������Ѵ�
  str = String.new
  normHash.each{|key, value|
    str = str + key.to_s + ":" + value.to_s + ","
  }

  # �֥饦����ɽ�������뤿��Τ��ޤ��ʤ�
  print "Content-type: text/html\n\n"
  print "<result>" + str + "</result>"
  
when "get_testkey" # ���������ƥ��Ȥθ�ͭ���̻�(���٤ν���¤�ͭ��)
  # ������ä��桼��id�ΰ��ֿ����������test_key���Ϥ��Ф����󤸤�ʤ����ȡ�

  # ���ߡ�
  #params["user_id"] = "uid"

  # ����⥸�塼��Υ��󥹥��󥹤����
  testHis = History.new

  # ����DB����³
  conn = testHis.open_setHistory(base_pgsql_host, base_pgsql_port, pgsql_user_name, pgsql_user_passwd)

  # ���ꤵ�줿user_id���ĺǿ���test_key���֤�
  str = testHis.get_testidByUserid(params["user_id"].to_s, conn)

  # ����DB��������
  testHis.close_setHistory(conn)
  
  # �֥饦����ɽ�������뤿��Τ��ޤ��ʤ�
  print "Content-type: text/html\n\n"
  print "<test_key>" + str + "</test_key>"

else # ����¾������̵��
  # �Ȥꤢ�������顼���̤Ǥ⸫���Ȥ�
  # Web�����Ф���ɥ�����Ȥ����
  http = Net::HTTP.new(base_eXist_host, base_eXist_port)
  req = Net::HTTP::Get.new(base_err_uri)
  res = http.request(req)

  # �֥饦����ɽ�������뤿��Τ��ޤ��ʤ�
  print "Content-type: text/html\n\n"
  print res.body
end
