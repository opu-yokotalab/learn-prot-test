#!/bin/env ruby
#
# ɾ�������⥸�塼��
#


# HTTP�̿�
require "net/http"

# REXML
require "rexml/document"

# Ruby-XSLT
#require "xml/xslt"

# ʸ���������Ѵ�
#require "kconv"

# Ruby-PostgreSQL
require "postgres"

# MD5�η׻���
require "digest/md5"


class Evaluate

  ## �����ޤ��ʽ�����ή��
  # ����ʬɾ����
  # ��������(eval_key)�Ȳ����������롼��id������id�������id��ȹ�
  # ɾ����̤�RDB�س�Ǽ
  
  # �����
  def initialize
    return 0
  end

  # �ץ�ɾ��
  # ������ques_pkey(���ꤷ������θ�ͭ���̻�)
  #       selectHash(�����˴ޤޤ������ʬ�򤷤��ϥå���)
  #       setHisHash(ques_pkey�����ꤵ�������ν�������)
  def preEvaluate(type, ques_pkey, value, setHisHash, base_eXist_host, base_eXist_port, base_db_uri)
    # ��������ˤ�ä�ɾ����ˡ���Ѥ���
    case type
    when "radio" then # ñ������
      result = evalRadioType(ques_pkey, value, setHisHash, base_eXist_host, base_eXist_port, base_db_uri)
    when "checkbox" then # ʣ������
      # ʣ�������ɾ���ϡ������������������θ����ɬ�פ�����
      return -1
    when "text" then # �ƥ���������
      # �ƥ��������Ϥ�ɾ���Ϻ��ν�ñ�����
      return -1
    else # ����¾��ĥ��
      # �����˼���
      return -1
    end

    # ɾ����̤��֤�
    return result
  end

  # ñ�����������ɾ��
  # ʣ�����򡢼�ͳ���ҤϺ���β���ȸ������ǤҤȤ�
  def evalRadioType(ques_pkey, value, setHisHash, base_eXist_host, base_eXist_port, base_db_uri)
    # ���򤫤���ꤷ����������
    # Web�����Ф���ɥ�����Ȥ����
    http = Net::HTTP.new(base_eXist_host, base_eXist_port)
    req = Net::HTTP::Get.new(base_db_uri + setHisHash["group_id"] + ".xml?_query=//problem_set/item[@id=%22" + setHisHash["ques_id"]  + "%22]")
    res = http.request(req)
    
    docElem = REXML::Document.new(res.body)
    elem = docElem.elements["//item"]
 
    # ���꤫��ɾ�����뤿��ξ�������
    # ����νŤ�
    crctWeight = elem.elements["./evaluate/weight"].attributes["correct"].to_i
    # ������νŤ�
    incrctWeight = elem.elements["./evaluate/weight"].attributes["incorrect"].to_i
    # ����������
    correctId = elem.elements["./evaluate/correct"].attributes["id"].to_s
    # ����
    score = elem.elements["./evaluate/score"].get_text.to_s.to_i
    # �������Ϳ������ݥ����
    crctPoint = elem.elements["./evaluate/point"].get_text.to_s.to_i

    # ����������������
    # (���������褬ʣ���λ��ˡĤȹͤ������ɻȤ����ɤ�����̯)
    crctAry = correctId.split(",")

    # �����
    correctNum = 0
    # �������
    incorrectNum = 0
    
    # ���������褬���򤫡�
    if crctAry.include?(value) then
      correctNum += 1
    else
      incorrectNum += 1
    end

    # ����������򤽤줾��νŤߤ�׻�
    cWeight = correctNum * crctWeight
    icWeight = incorrectNum * incrctWeight
    totalWeight = (correctNum * crctWeight) + (incorrectNum * incrctWeight)
    
    # �ǽ�Ū��ɾ�����
    total_point = 0
    if totalWeight >= score then # ���ͤ���礭��
      total_point = crctPoint
    else
      total_point = 0
    end

    # ��ͭ���̻�(pkey)������
    pkeyInt = Time.now.tv_sec + rand(1000000)
    pkey = Digest::MD5.new(pkeyInt.to_s).to_s

    # ��Ͽ����
    evalTime = Date.today.to_s + " " + Time.now.strftime("%X")   
    
    # ɾ����̤��֤�
    evalResultHash = Hash.new
    evalResultHash = {"chk_selection" => value.to_s, "eval_result" => total_point.to_s, "crct_weight" => cWeight.to_s, "incrct_weight" => icWeight.to_s, "total_weight" => totalWeight.to_s, "eval_pkey" => pkey, "time" => evalTime, "total_point" => crctPoint.to_s}

    return evalResultHash
  end

  # ɾ����̤�������(mode=result)
  def evaluate(tbl)
    # ����������ɾ����̤��֤�

    # ������ޤȤ��
    markHash = Hash.new
    tbl.each{|tblLine|
      markHash[tblLine["group_id"]] = tblLine["group_mark"].to_i
    }

    # ���롼�פ��Ȥγ�������������ޤȤ��
    grpPntHash = Hash.new{|h,key|h[key] = []}
    tbl.each{|tblLine|
      grpPntHash[tblLine["group_id"]] << tblLine["eval_result"].to_i
    }
    # ���줾��Υ��롼�פ�������û�
    sumNum = 0
    grpPntHash.each{|key, value|
      value.each{|valLine|
        sumNum += valLine.to_i
      }
      grpPntHash[key] = sumNum
      sumNum = 0
    }
#p tbl
    # ���롼�פ��Ȥ����������
    grpFullPntHash = Hash.new{|h,key|h[key] = []}
    tbl.each{|tblLine|
      grpFullPntHash[tblLine["group_id"]] << tblLine["total_point"].to_i
    }
    # ���줾��Υ��롼�פ�������û�(������)
    sumNum = 0
    grpFullPntHash.each{|key, value|
      value.each{|valLine|
        sumNum += valLine.to_i
      }
      grpFullPntHash[key] = sumNum
      sumNum = 0
    }

    # ����Ψ��׻�
    pntRateHash = Hash.new
    grpFullPntHash.each{|key, value|
      pntRateHash[key] = grpPntHash[key].to_f / grpFullPntHash[key].to_f
    }

    # ����Ψ*�����Ǽºݤ�������׻�
    normalizeHash = Hash.new
    pntRateHash.each{|key,value|
      normalizeHash[key] = ((markHash[key] * pntRateHash[key]).round).to_s
    }
    return normalizeHash
  end
end
