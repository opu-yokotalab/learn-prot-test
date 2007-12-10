#!/bin/env ruby
#
# ����Ͽ�ѥ⥸�塼��
# ������ 07/12/04
#

# REXML
#require "rexml/document"

# Ruby-XSLT
#require "xml/xslt"

# ʸ���������Ѵ�
#require "kconv"

# Ruby-PostgreSQL
require "postgres"

# MD5�η׻���
require "digest/md5"

# ����
require "date"

class History

  ## ����ư��
  # �ڽ��������
  # ������˺�����������ơ��֥�򸵤���������

  # �����
  def initialize
    return 0
  end

  # ����DB����³
  def open_setHistory(base_pgsql_host, base_pgsql_port, pgsql_user_name, pgsql_user_passwd)
    conn = PGconn.connect(base_pgsql_host, base_pgsql_port, "", "", "examination_logs", pgsql_user_name, pgsql_user_passwd)
    return conn
  end

  # ����DB����
  def close_setHistory(conn)
    conn.close
    return 0
  end
  
  # ����ơ��֥�����Ƥ�RDB�˳�Ǽ
  def put_setHistory(user_id, test_id, tblLine, conn)
    # �ȥ�󥶥���������
    res = conn.exec("BEGIN;")
    res.clear
    
    # �ơ��֥���ͤ������
    sql = "INSERT INTO examination (user_id, test_id, group_id, group_mark, ques_id, ques_pass, test_key, time, examination_pkey) VALUES ('" + user_id + "','" + test_id + "','" + tblLine["group_id"] + "','" + tblLine["mark"] + "','" + tblLine["item_id"] + "','" + tblLine["ques_pass"] + "','" + Digest::MD5.new(tblLine["time"]).to_s + "','" + tblLine["time"] + "','" + tblLine["test_key"] + "')"
    res = conn.exec(sql)
    res.clear      
    
    # ���ߥå�
    res = conn.exec("COMMIT;")
    if res.status != PGresult::COMMAND_OK
      res.clear
      raise "commit���ޥ�ɤ˼��Ԥ��ޤ�����"
    end
    res.clear           
    
    # ����Хå�
    #res = conn.exec("ROLLBACK;")
    #res.clear
    
    #res = conn.exec("select * from examination;")
    res = conn.query("select * from examination;")
    
    #      p res
    res.clear

    return 0
  end

  # ������֤�
  def get_setHistory(pkey, conn)
    # �����Ǽ��
    setHisHash = Hash.new

    # ��礻ʸ����
    resStr = "select * from examination where examination_pkey='" + pkey + "';"

    # ��礻
    res = conn.exec(resStr)

    res.result.each{|resultLine|
      resultLine.each_with_index{|tuple, idx|
        setHisHash[res.fields[idx]] = tuple
      }
    }
    
    return setHisHash
  end
  
  # �ץ�ɾ���������Ͽ
  def put_preEvalHistory(eval_key, evalResultHash, conn)
    # �ȥ�󥶥���������
    res = conn.exec("BEGIN;")
    res.clear
    # �ơ��֥���ͤ������
    sql = "INSERT INTO pre_evaluate (evaluate_pkey, eval_key, chk_selection, eval_result, time, comp_eval, crct_total_weight, incrct_total_weight, total_weight, total_point) VALUES ('" + evalResultHash["eval_pkey"] + "','" + eval_key + "','" + evalResultHash["chk_selection"] + "','" + evalResultHash["eval_result"] + "','" + evalResultHash["time"] + "','false','" + evalResultHash["crct_weight"] + "','" + evalResultHash["incrct_weight"] + "','" + evalResultHash["total_weight"] + "','" + evalResultHash["total_point"] + "')"
    res = conn.exec(sql)
    res.clear      
    
    # ���ߥå�
    res = conn.exec("COMMIT;")
    if res.status != PGresult::COMMAND_OK
      res.clear
      raise "commit���ޥ�ɤ˼��Ԥ��ޤ�����"
    end
    res.clear           
    
    # ����Хå�
    #res = conn.exec("ROLLBACK;")
    #res.clear
    
    #res = conn.exec("select * from examination;")
    #res = conn.query("select * from examination;")
    
    #      p res
    #res.clear

    return 0
  end

  # �ץ�ɾ����������֤�
  def get_preEvalHistory(pkey, conn)
    # �����Ǽ��
    preHisHash = Hash.new

    # ��礻ʸ����(���ֿ������Ԥ�1��)
    resStr = "select * from pre_evaluate where eval_key='" + pkey  +"' order by time desc offset 0 limit 1;"

    # ��礻
    res = conn.exec(resStr)
#p res.result.size
    res.result.each{|resultLine|
      resultLine.each_with_index{|tuple, idx|
        preHisHash[res.fields[idx]] = tuple
      }
    }
    
    return preHisHash    
  end                        
  
  # ���ꤷ�������������Ͽ
  def put_evalHistory(pkey, conn)
    # �ȥ�󥶥���������
    res = conn.exec("BEGIN;")
    res.clear
#p pkey
   # ��礻ʸ����
    sql = "update pre_evaluate set comp_eval='true' where evaluate_pkey='" + pkey + "';"
    res = conn.exec(sql)
    res.clear      
    
    # ���ߥå�
    res = conn.exec("COMMIT;")
    if res.status != PGresult::COMMAND_OK
      res.clear
      raise "commit���ޥ�ɤ˼��Ԥ��ޤ�����"
    end
    res.clear           
    
    # ����Хå�
    #res = conn.exec("ROLLBACK;")
    #res.clear
    
    #res = conn.exec("select * from examination;")
    #res = conn.query("select * from examination;")
    
    #      p res
    #res.clear

    return 0
  end

  # ���ꤷ��������������֤�
  def get_evalHistory(test_key, conn)
    # ��������ơ��֥�����
    # [{group_id => "", group_mark => "", eval_result => "", com_eval="ture", total_point = ""}, ...]

    # �����Ǽ��
    evalAry = Array.new
    eval_key = String.new
    group_id = String.new
    group_mark = String.new
    eval_result = String.new
    total_point = String.new
    
    # ��礻ʸ����
    resStr = "select * from examination where test_key='" + test_key  +"';"

    # ��礻
    res = conn.exec(resStr)
    
    # ���������Τ��줾��ˤĤ���
    res.each{|resultLine|
      # ɬ�פʤ�Τ�ȴ���Ф�
      eval_key = resultLine[res.fields.index("examination_pkey")]
      group_id = resultLine[res.fields.index("group_id")]
      group_mark = resultLine[res.fields.index("group_mark")]

      # �ץ�ɾ���Υơ��֥�ˤ�
      sqlStr = "select * from pre_evaluate where eval_key='" + resultLine[res.fields.index("examination_pkey")] + "' and comp_eval='true';"
      sql = conn.exec(sqlStr)

      sql.each{|sqlLine|
        eval_result = sqlLine[sql.fields.index("eval_result")]
        total_point = sqlLine[sql.fields.index("total_point")] 
      }
      # �ϥå��������˳�Ǽ
      evalAry << {"group_id" => group_id, "group_mark" => group_mark, "eval_result" => eval_result, "total_point" => total_point, "eval_key" => eval_key}
    }

    return evalAry   
  end

  # ���ꤵ�줿user_id����ĺǿ���test_key���֤�
  def get_testidByUserid(user_id, conn)

    # ��礻ʸ����(���ֿ������Ԥ�1��)
    resStr = "select test_key from examination where user_id='" + user_id  +"' order by time desc offset 0 limit 1;"
    
    # ��礻
    res = conn.exec(resStr)

    return  res.result.to_s   
  end

end

# ñ�ΤǤ�ư���ǧ
if __FILE__ == $0 then


end
