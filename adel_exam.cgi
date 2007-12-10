#!/bin/env ruby
#
# テスト機構インタフェース
#

## -- 追加モジュールの宣言 --

# CGI
require "cgi"

# HTTP通信
require "net/http"

# REXML
require "rexml/document"

# Ruby-XSLT
#require "xml/xslt"

# 文字コード変換
require "kconv"

# MD5の計算用
require "digest/md5"

# 履歴モジュール
require "./func/history"

# 出題モジュール
require "./func/set_questions" 

# 評価モジュール
require "./func/evaluate"


## -- include --

# XML操作用
include REXML


## -- 環境変数 --

# eXist, postgreSQLの接続先のホスト
base_eXist_host = 'localhost'
# eXist用接続ポート
base_eXist_port = 8080

# postgreSQL関連
# eXist, postgreSQLの接続先のホスト
base_pgsql_host = 'localhost'
# postgreSQL用接続ポート
base_pgsql_port = 5432
# ユーザ名
pgsql_user_name = "postgres"
# パスワード
pgsql_user_passwd = "postnamabu"

# 問題DB
base_db_uri = "/exist/rest//db/home/learn/examination/db/"

# XSLTスタイルシート
base_xslt_all_uri = "/exist/rest//db/home/learn/examination/test.xsl"
base_xslt_eval_uri = "/exist/rest//db/home/learn/examination/evaluate.xsl"

# XHTML変換時に問題形式からinput要素のtype属性値
# を決定するための変換テーブル
base_inputType_uri = "/exist/rest//db/home/learn/examination/input_type.xml"


# 以下テスト用 
# 呼び出し記述
#base_call_uri = "/exist/rest//db/home/learn/examination/examination_prot.xml" 
base_call_uri = "/exist/rest//db/home/learn/examination/saiki_examin.xml"

# エラー時に表示するxhtml
base_err_uri = "/exist/rest//db/home/learn/examination/error.xml"


## -- 本処理 --

# CGIの引数関連
qs = CGI.new
params = qs.params

## 動作モード
## 出題、プレ評価、解答確定、テスト全体の評価

#params = {"user_id" => "uid", "mode" => "set"}
#params = {"mode" => "pre_evaluate"}
#params = {"mode" => "evaluate"}
#params = {"mode" => "result"}
#params = {"mode" => "get_testkey"}

# 動作モード別に振り分け
case params["mode"].to_s
when "set" then # 出題  
  # Webサーバからドキュメントを取得
  http = Net::HTTP.new(base_eXist_host, base_eXist_port)
  req = Net::HTTP::Get.new(base_call_uri)

  res = http.request(req)

  # ダミーの呼び出し記述
  params["src"] = res.body

  ## 本処理  
  # DOMオブジェクトに変換
  tmpDoc = REXML::Document.new(params["src"].to_s)

  # ユーザid取得
  user_id = params["user_id"].to_s
  # ユーザidを指定して、出題機構のインスタンスを生成
  setQues = Set_question.new(user_id)
  
  # 呼び出し記述から出題テーブルを生成
  setTable = Array.new
  setTable = setQues.make_table(tmpDoc, base_eXist_host, base_eXist_port, base_db_uri)

  # 出題テーブルから出題履歴を作成
  # テストの固有識別子を作成
  setHis = History.new
  
  # 履歴DBに接続
  conn = setHis.open_setHistory(base_pgsql_host, base_pgsql_port, pgsql_user_name, pgsql_user_passwd)
  
  # テーブルの要素ごとに処理
  setTable.each{|tblLine|    
    # 1ラインずつ履歴を記録    
    setHis.put_setHistory(user_id, setQues.get_testId, tblLine, conn)
  }

  # 履歴DBから切断
  setHis.close_setHistory(conn)

  # 出題テーブルから中間XMLを生成
  setElem = REXML::Element.new
  setElem = setQues.make_xml(setTable, base_eXist_host, base_eXist_port, base_db_uri, base_inputType_uri)
  
  # 中間XMLをXSLTを用いてXHTMLに変換
  xhtmlElem = REXML::Element.new
  xhtmlElem = setQues.make_xhtml(setElem, base_eXist_host, base_eXist_port, base_xslt_all_uri)

  # ブラウザで表示させるためのおまじない
  print "Content-type: text/html\n\n"
  print xhtmlElem

when "pre_evaluate" then # プレ評価
  ## ダミー解答
  # 受け取った解答情報を処理
  #params["selected"] = "q4_0_0" # 正解
  #params["selected"] = "q4_0_1" # 不正解
  
  #params["type"] = "radio" # 単一選択式問題
  #params["type"] = "checked" # 複数選択
  #params["value"] = "value" # テキスト入力

  #params["value"] = "0" # 選んだ選択肢
  #params["value"] = "1"
  #params["value"] = "2"

  # あるテストで出題された問題の固有識別子
  #params["ques_pkey"] = "f2ad3984f7e59f93863af5bf577303bb"


  ## 本処理
  # 評価モジュールのインスタンス生成
  evalQues = Evaluate.new
  
  # 評価結果格納用のハッシュ
  evalResultHash = Hash.new
  
  # 出題テーブルから出題履歴を作成
  # テストの固有識別子を作成
  # 履歴モジュールのインスタンス作成
  setHis = History.new

  # 履歴DBに接続
  conn = setHis.open_setHistory(base_pgsql_host, base_pgsql_port, pgsql_user_name, pgsql_user_passwd)
  
  # 出題履歴
  setHisHash = Hash.new
  setHisHash = setHis.get_setHistory(params["ques_pkey"].to_s, conn)
  
  # プレ評価
  evalResultHash = evalQues.preEvaluate(params["type"].to_s, params["ques_pkey"].to_s, params["value"].to_s, setHisHash)
#p evalResultHash
  # 評価履歴を記録
  setHis.put_preEvalHistory(params["ques_pkey"].to_s, evalResultHash, conn)
  
  # 履歴DBから切断
  setHis.close_setHistory(conn)

  # ブラウザで表示させるためのおまじない
  print "Content-type: text/html\n\n"
  print "<e_result>" + evalResultHash["eval_result"]  + "</e_result>"
  
when "evaluate" then # テストの評価
  # プレ評価で得点は出してるのでまとめるだけ…なはず
  # ques_pkeyと各グループid、問題idで一番新しい物だけを取得
  # 正解、不正解のxhtmlを返して、評価履歴のcomp_evalをtrueにする

  # ダミー
  #params["ques_pkey"] = "7529c20403cba45d9f5caa751a6af921"
  #params["name"] = "q4_0"
  
  # 履歴モジュールのインスタンスを作成
  evalHis = History.new

  # 指定無しで出題機構のインスタンスを生成(履歴は作らない)
  setQues = Set_question.new("eval_mode")

  # 履歴格納用のハッシュ
  setHisHash = Hash.new
  evalHisHash = Hash.new
  
  # 履歴DBに接続
  conn = evalHis.open_setHistory(base_pgsql_host, base_pgsql_port, pgsql_user_name, pgsql_user_passwd)

  # 評価モジュールのインスタンス生成
  # 解答確定に評価機構は要らない？
  evalQues = Evaluate.new

  # ques_pkeyからプレ評価履歴を取得
  evalHisHash = evalHis.get_preEvalHistory(params["ques_pkey"].to_s, conn)

  # 解答履歴が無かった場合
  # 未解答マークを付けて解答ログに記録?
#p evalHisHash.size
  if evalHisHash.size == 0 then
    # 出題履歴
    setHisHash = Hash.new
    setHisHash = evalHis.get_setHistory(params["ques_pkey"].to_s, conn)
#p setHisHash
    # 未解答の場合に、未解答のログをつける
    evalResultHash = Hash.new
    evalResultHash = evalQues.preEvaluate("radio", "NULL", "NULL", setHisHash)
#p evalResultHash
    # 評価履歴を記録
    evalHis.put_preEvalHistory(params["ques_pkey"].to_s, evalResultHash, conn)
  end

  # 確定した解答にマークをつける
  evalHis.put_evalHistory(evalHisHash["evaluate_pkey"].to_s, conn)
  
  # 評価結果に応じたxhtmlを生成
  # ques_pkeyから出題履歴を取得
  setHisHash = evalHis.get_setHistory(params["ques_pkey"].to_s, conn)
  
  # 履歴DBから切断
  evalHis.close_setHistory(conn)

  # 出題履歴から簡易的な出題テーブルを作成
  tblAry = Array.new
  tmpSetHash = {"group_id" => setHisHash["group_id"], "mark" => setHisHash["group_mark"], "item_id" => setHisHash["ques_id"], "ques_pass" => setHisHash["ques_pass"],"ques_type" => setHisHash["ques_id"] , "selection_type" => "", "ques_correct" => "", "time" => "", "test_key" => ""}
  tblAry << tmpSetHash
  
  # 出題テーブルから中間xmlを作成
  setElem = REXML::Element.new
  setElem = setQues.make_xml(tblAry, base_eXist_host, base_eXist_port, base_db_uri, base_inputType_uri)

  # 必要な部分木を取り出しxhtmlを生成
  xhtmlElem = REXML::Element.new
#puts setElem
  xhtmlElem = setQues.make_xhtml(setElem.elements["//item"], base_eXist_host, base_eXist_port, base_xslt_eval_uri)

  # 提示に必要な情報を付け加える
  if evalHisHash["eval_result"] != "0" then
    xhtmlElem.elements["/div/div/h2"].add_text(Kconv.kconv("正解!", Kconv::UTF8))
  else
    xhtmlElem.elements["/div/div/h2"].add_text(Kconv.kconv("不正解...", Kconv::UTF8))
  end

  
  # ブラウザで表示させるためのおまじない
  print "Content-type: text/html\n\n"
  print xhtmlElem

when "result" then # テスト全体の評価結果出力
  # 正規化した評価結果を渡す
  # {"group_id" => 得点(配点*得点率), ...}
  # 得点率 = グループ単位で獲得した得点/グループから出題された問題の総得点

  #params["test_key"] = "6a0027335cdc26cbd4a0ec5f13c0f4b7"
  
  # 履歴モジュールのインスタンスを作成
  evalHis = History.new

  # 評価モジュールのインスタンスを生成
  evalQues = Evaluate.new

  # 履歴格納用のハッシュ
  evalHisHash = Hash.new
  
  # 履歴DBに接続
  conn = evalHis.open_setHistory(base_pgsql_host, base_pgsql_port, pgsql_user_name, pgsql_user_passwd)

  # テスト全体の評価に必要な情報を取得
  tblEval = evalHis.get_evalHistory(params["test_key"].to_s, conn)
#p tblEval  

  # 評価結果に未評価部分がある
  reEvalFlag = 0 # 再評価のフラグ
  tblEval.each{|tblLine|
    if tblLine["eval_result"] == "" then
      # 未回答状態でプレ評価
      # 出題履歴
      setHisHash = Hash.new
      setHisHash = evalHis.get_setHistory(tblLine["eval_key"].to_s, conn)
#p setHisHash
      # 未解答の場合に、未解答のログをつける
      evalResultHash = Hash.new
      evalResultHash = evalQues.preEvaluate("radio", "NULL", "NULL", setHisHash)
#p evalResultHash
      # 評価履歴を記録
      evalHis.put_preEvalHistory(tblLine["eval_key"].to_s, evalResultHash, conn)      

      # ques_pkeyからプレ評価履歴を取得
      evalHisHash = evalHis.get_preEvalHistory(tblLine["eval_key"].to_s, conn)

      # 確定した解答にマークをつける
      evalHis.put_evalHistory(evalHisHash["evaluate_pkey"].to_s, conn)

      # 再評価を行う
      reEvalFlag = 1
    end
  }

  if reEvalFlag == 1 then # 再評価が必要
    # 再度テスト全体の評価に必要な情報を取得
    tblEval = evalHis.get_evalHistory(params["test_key"].to_s, conn)
#p tblEval
    # フラグの初期化
    reEvalFlag = 0
  end

  # 履歴DBから切断
  evalHis.close_setHistory(conn)

  # 評価結果の正規化
  normHash = Hash.new
  normHash = evalQues.evaluate(tblEval)

  # ハッシュを受け渡すための形式に変換
  str = String.new
  normHash.each{|key, value|
    str = str + key.to_s + ":" + value.to_s + ","
  }

  # ブラウザで表示させるためのおまじない
  print "Content-type: text/html\n\n"
  print "<result>" + str + "</result>"
  
when "get_testkey" # 作成したテストの固有識別子(一度の出題限り有効)
  # 受け取ったユーザidの一番新しい出題のtest_keyを渡せばいいんじゃないかと。

  # ダミー
  #params["user_id"] = "uid"

  # 履歴モジュールのインスタンスを作成
  testHis = History.new

  # 履歴DBに接続
  conn = testHis.open_setHistory(base_pgsql_host, base_pgsql_port, pgsql_user_name, pgsql_user_passwd)

  # 指定されたuser_idをもつ最新のtest_keyを返す
  str = testHis.get_testidByUserid(params["user_id"].to_s, conn)

  # 履歴DBから切断
  testHis.close_setHistory(conn)
  
  # ブラウザで表示させるためのおまじない
  print "Content-type: text/html\n\n"
  print "<test_key>" + str + "</test_key>"

else # その他・指定無し
  # とりあえずエラー画面でも見せとく
  # Webサーバからドキュメントを取得
  http = Net::HTTP.new(base_eXist_host, base_eXist_port)
  req = Net::HTTP::Get.new(base_err_uri)
  res = http.request(req)

  # ブラウザで表示させるためのおまじない
  print "Content-type: text/html\n\n"
  print res.body
end
