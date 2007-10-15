#!/usr/bin/env ruby
# システムプロトタイプ
# 作成日：05/12/25
# 更新日：05/12/25
#

# QueryString取得
require "cgi"

# 出題クラス
require "./test/test_db"

# 評価クラス
require "./test/evaluate"


class Evaluate_cgi

#include Test
#include Evalute

  # コンストラクタ
  def initialize
    # CGI
    qs = CGI.new
    @params = qs.params
#    @params = {"q1" => "0", "q2" => "1", "q3" => "2"}
    # 出題
    @t_db = Test_db.new
    # 評価
    @eva = Evaluate.new
    # 評価結果
    @result = Hash.new
    # 履歴保存用
    @his = Hash.new
    @his = @eva.get_history
  end

  # 問題形式ごとの選択肢の出力
  def selection_type(id)
    return @t_db.get_itemtype
  end

  # 解答を渡す
  def eva_response
    @eva.response = @params
#    p @params
    @result = @eva.evaluate_response
#    p @result
  end
  
  # HTML頭部の出力
  def html_start
    print "Content-type: text/html\n\n"
    print "<?xml version=\"1.0\" encoding=\"euc-jp\" standalone=\"no\"?>\n"
    print "<!DOCTYPE html\n PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"\n\"http://www.w3c.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n"
    print "<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"ja\" lang=\"ja\">\n"
    print "<head>\n"
    print "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=euc-jp\" />\n"
    print "<title>評価</title>\n"
    print "</head>\n"
    print "<body>\n"
  end

  # 正解,不正解の表示
  def crct_msg(key)
    if @result[key] == true then
      return "正解"
    else
      return "不正解"
    end
  end
    

  # HTML問題部の出力
  def html_problem
    @params.each{|key, val|
      @t_db.create_doc(key)
      print "<fieldset>\n"
      print "<legend>#{key}:#{crct_msg(key)}</legend>\n"
#      val.each{|v|
        @t_db.set_itemid(@his[key])
        print "問題:" + @t_db.get_prob + "<br /><br />\n"
        print "選択肢:<br />\n" 
      print html_selection
 #     }
      print "<br />\n"
      print "あなたの解答:"
#      res_ary = @t_db.get_response
      val.each{|v|
        if v == "null" then
          print "未回答"
        else
          print "選択肢:" + (v.to_i + 1).to_s + " "
        end
      }
      print "<br />\n"
      print "答え:"
      print html_correct
      print "<br /><br />\n"
      print html_explanation + "<br />\n"
      print "</fieldset>\n"
      print "<br />\n"
    }
  end

  # HTML選択肢部の出力
  def html_selection
    res_ary = @t_db.get_response
    str = ""
    cnt = 0
    res_ary.each{|s|
      str = str +  "選択肢#{cnt + 1}:#{res_ary[cnt]} \n"
      cnt += 1
    }
    return str + "<br />\n"
  end

  # HTML正解部の出力
  def html_correct
    res_ary = @t_db.get_response
    crct_ary = @t_db.get_correct
    str = ""
    crct_ary.each{|s|
      str = str +  "選択肢:#{s.to_i + 1} \n"
    }
    return str + "<br />\n"
  end

  # HTML部の出力
  def html_explanation
    return "解答,解説:" + @t_db.get_explanation
  end

  # HTML尾部の出力
  def html_end
    print "<br />\n"
    print "</body>\n"
    print "</html>\n"
  end    

end


st = Evaluate_cgi.new


st.html_start
st.eva_response
st.html_problem
st.html_end
