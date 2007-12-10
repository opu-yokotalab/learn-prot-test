#!/bin/env ruby
#
# ログ記録用モジュール
# 作成日 07/12/04
#

# REXML
#require "rexml/document"

# Ruby-XSLT
#require "xml/xslt"

# 文字コード変換
#require "kconv"

# Ruby-PostgreSQL
require "postgres"

# MD5の計算用
require "digest/md5"

# 日付
require "date"

class History

  ## 基本動作
  # 【出題履歴】
  # 出題時に作成した出題テーブルを元に履歴を作成

  # 初期化
  def initialize
    return 0
  end

  # 履歴DBに接続
  def open_setHistory(base_pgsql_host, base_pgsql_port, pgsql_user_name, pgsql_user_passwd)
    conn = PGconn.connect(base_pgsql_host, base_pgsql_port, "", "", "examination_logs", pgsql_user_name, pgsql_user_passwd)
    return conn
  end

  # 履歴DB切断
  def close_setHistory(conn)
    conn.close
    return 0
  end
  
  # 出題テーブルの内容をRDBに格納
  def put_setHistory(user_id, test_id, tblLine, conn)
    # トランザクション処理
    res = conn.exec("BEGIN;")
    res.clear
    
    # テーブルに値を入れる
    sql = "INSERT INTO examination (user_id, test_id, group_id, group_mark, ques_id, ques_pass, test_key, time, examination_pkey) VALUES ('" + user_id + "','" + test_id + "','" + tblLine["group_id"] + "','" + tblLine["mark"] + "','" + tblLine["item_id"] + "','" + tblLine["ques_pass"] + "','" + Digest::MD5.new(tblLine["time"]).to_s + "','" + tblLine["time"] + "','" + tblLine["test_key"] + "')"
    res = conn.exec(sql)
    res.clear      
    
    # コミット
    res = conn.exec("COMMIT;")
    if res.status != PGresult::COMMAND_OK
      res.clear
      raise "commitコマンドに失敗しました。"
    end
    res.clear           
    
    # ロールバック
    #res = conn.exec("ROLLBACK;")
    #res.clear
    
    #res = conn.exec("select * from examination;")
    res = conn.query("select * from examination;")
    
    #      p res
    res.clear

    return 0
  end

  # 履歴を返す
  def get_setHistory(pkey, conn)
    # 履歴格納先
    setHisHash = Hash.new

    # 問合せ文を作る
    resStr = "select * from examination where examination_pkey='" + pkey + "';"

    # 問合せ
    res = conn.exec(resStr)

    res.result.each{|resultLine|
      resultLine.each_with_index{|tuple, idx|
        setHisHash[res.fields[idx]] = tuple
      }
    }
    
    return setHisHash
  end
  
  # プレ評価の履歴を記録
  def put_preEvalHistory(eval_key, evalResultHash, conn)
    # トランザクション処理
    res = conn.exec("BEGIN;")
    res.clear
    # テーブルに値を入れる
    sql = "INSERT INTO pre_evaluate (evaluate_pkey, eval_key, chk_selection, eval_result, time, comp_eval, crct_total_weight, incrct_total_weight, total_weight, total_point) VALUES ('" + evalResultHash["eval_pkey"] + "','" + eval_key + "','" + evalResultHash["chk_selection"] + "','" + evalResultHash["eval_result"] + "','" + evalResultHash["time"] + "','false','" + evalResultHash["crct_weight"] + "','" + evalResultHash["incrct_weight"] + "','" + evalResultHash["total_weight"] + "','" + evalResultHash["total_point"] + "')"
    res = conn.exec(sql)
    res.clear      
    
    # コミット
    res = conn.exec("COMMIT;")
    if res.status != PGresult::COMMAND_OK
      res.clear
      raise "commitコマンドに失敗しました。"
    end
    res.clear           
    
    # ロールバック
    #res = conn.exec("ROLLBACK;")
    #res.clear
    
    #res = conn.exec("select * from examination;")
    #res = conn.query("select * from examination;")
    
    #      p res
    #res.clear

    return 0
  end

  # プレ評価の履歴を返す
  def get_preEvalHistory(pkey, conn)
    # 履歴格納先
    preHisHash = Hash.new

    # 問合せ文を作る(一番新しい行を1件)
    resStr = "select * from pre_evaluate where eval_key='" + pkey  +"' order by time desc offset 0 limit 1;"

    # 問合せ
    res = conn.exec(resStr)
#p res.result.size
    res.result.each{|resultLine|
      resultLine.each_with_index{|tuple, idx|
        preHisHash[res.fields[idx]] = tuple
      }
    }
    
    return preHisHash    
  end                        
  
  # 確定した解答の履歴を記録
  def put_evalHistory(pkey, conn)
    # トランザクション処理
    res = conn.exec("BEGIN;")
    res.clear
#p pkey
   # 問合せ文を作る
    sql = "update pre_evaluate set comp_eval='true' where evaluate_pkey='" + pkey + "';"
    res = conn.exec(sql)
    res.clear      
    
    # コミット
    res = conn.exec("COMMIT;")
    if res.status != PGresult::COMMAND_OK
      res.clear
      raise "commitコマンドに失敗しました。"
    end
    res.clear           
    
    # ロールバック
    #res = conn.exec("ROLLBACK;")
    #res.clear
    
    #res = conn.exec("select * from examination;")
    #res = conn.query("select * from examination;")
    
    #      p res
    #res.clear

    return 0
  end

  # 確定した解答の履歴を返す
  def get_evalHistory(test_key, conn)
    # 解答履歴テーブルを作成
    # [{group_id => "", group_mark => "", eval_result => "", com_eval="ture", total_point = ""}, ...]

    # 履歴格納先
    evalAry = Array.new
    eval_key = String.new
    group_id = String.new
    group_mark = String.new
    eval_result = String.new
    total_point = String.new
    
    # 問合せ文を作る
    resStr = "select * from examination where test_key='" + test_key  +"';"

    # 問合せ
    res = conn.exec(resStr)
    
    # 該当するものそれぞれについて
    res.each{|resultLine|
      # 必要なものを抜き出し
      eval_key = resultLine[res.fields.index("examination_pkey")]
      group_id = resultLine[res.fields.index("group_id")]
      group_mark = resultLine[res.fields.index("group_mark")]

      # プレ評価のテーブルにも
      sqlStr = "select * from pre_evaluate where eval_key='" + resultLine[res.fields.index("examination_pkey")] + "' and comp_eval='true';"
      sql = conn.exec(sqlStr)

      sql.each{|sqlLine|
        eval_result = sqlLine[sql.fields.index("eval_result")]
        total_point = sqlLine[sql.fields.index("total_point")] 
      }
      # ハッシュを配列に格納
      evalAry << {"group_id" => group_id, "group_mark" => group_mark, "eval_result" => eval_result, "total_point" => total_point, "eval_key" => eval_key}
    }

    return evalAry   
  end

  # 指定されたuser_idを持つ最新のtest_keyを返す
  def get_testidByUserid(user_id, conn)

    # 問合せ文を作る(一番新しい行を1件)
    resStr = "select test_key from examination where user_id='" + user_id  +"' order by time desc offset 0 limit 1;"
    
    # 問合せ
    res = conn.exec(resStr)

    return  res.result.to_s   
  end

end

# 単体での動作確認
if __FILE__ == $0 then


end
