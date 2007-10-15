#!/usr/bin/env ruby
#
# テスト問題出題プログラム(仮)
# ver 0.0.1
# 作成日 05/12/08
# 最終更新日 05/12/29

  
# XML操作
require "rexml/document"
# 文字コード変換
require "kconv"
# 共通定数
require "./test/value"
# 履歴
require "./test/history"

class Test_db
  
  # XML操作
  include REXML
  # 共通定数
  include Value
  
  # コンストラクタ
  def initialize
    # REXML::Document
    @doc = nil
    # 問題群id
    @problem_id
    # item要素のid
    @item_id = nil
    # 履歴クラス
    @his_mod = History.new
    # 履歴
    @his = Hash.new
  end
  
  # オープン
  def create_doc(filename)
    File.open(Value::DB_base + filename + ".xml") {|fp|
      # 空白のみのテキストノードを無視
      @doc = REXML::Document.new(fp, {:ignore_whitespace_nodes => :all})
      @problem_id = filename
    }
  end
  
  # 出題するitem要素のidをセット
  def set_itemid(id)
    # 引数がrandomなら要素数以下の乱数を生成
    if id == "random" then
      @item_id = rand(get_ElementsLength("//item")).to_s
      @his.store(@problem_id, @item_id)
      return @item_id
    end
    # idが指定されていたらセット
    @item_id = id
    @his.store(@problem_id, @item_id)
    return @item_id
  end 
  
  # prob要素の子ノードの取得
  def get_prob()
    lis =  REXML::XPath.first(@doc,"//item[@id=\"" + @item_id + "\"]/prob/node()")
    return lis.to_s.kconv(Kconv::EUC, Kconv::UTF8)
  end
  
  # response要素の子ノードの取得
  # out : Array
  def get_response()
    lis = REXML::XPath.match(@doc,"//item[@id=\"" + @item_id + "\"]/response/node()")
    # テキストノードの文字コードを変換し配列に格納
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
  
  # hints要素の子ノードの取得
  def get_hints()
    lis =  REXML::XPath.first(@doc,"//item[@id=\"" + @item_id + "\"]/hints/node()")
    return lis.to_s.kconv(Kconv::EUC, Kconv::UTF8)
  end
  
  # correct要素のid属性値の取得
  # out : Array
  def get_correct()
    lis =  REXML::XPath.first(@doc,"//item[@id=\"" + @item_id + "\"]/correct")
    # 属性値を","で分割し配列に
    return lis.attributes["id"].split(",")
  end
  
  # explanation要素の子ノードの取得
  def get_explanation()
    lis =  REXML::XPath.first(@doc,"//item[@id=\"" + @item_id + "\"]/explanation/node()")
    return lis.to_s.kconv(Kconv::EUC, Kconv::UTF8)
  end
  
  # 指定したノード数のカウント
  def get_ElementsLength(path) 
    elems =  @doc.elements.to_a(path).collect
    return elems.length
  end
  
  # item要素のtype属性の値を取得する
  def get_itemtype()
    lis =  REXML::XPath.first(@doc,"//item[@id=\"" + @item_id + "\"]")
    return lis.attributes["type"]
  end
  
  # 履歴作成
  def put_history()
    @his_mod.his = @his
    @his_mod.history_puts
    #      p @his_mod.history_gets
  end
  
end
  

# 試験動作用
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
