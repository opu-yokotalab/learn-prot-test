#!/usr/bin/env ruby
# テスティングシステムプロトタイプ
# 作成日：05/12/22
# 更新日：05/12/26
#

# QueryString取得
require "cgi"

# テストDB基本操作クラス
require "./test/test_db"

# 履歴
require "./test/history"

class Start

#  include TEST

  # コンストラクタ
  def initialize
    qs = CGI.new
    @params = qs.params
#    @params = {"q1" => "0", "q2" => "1", "q3" => "2"}
    @t_db = Test_db.new
    @his_mod = History.new
  end

  # 問題形式ごとの選択肢の出力
  def selection_type(id)
    return @t_db.get_itemtype
  end

  # HTML頭部の出力
  def html_start
    print "Content-type: text/html\n\n"
    print "<?xml version=\"1.0\" encoding=\"euc-jp\" standalone=\"no\"?>\n"
    print "<!DOCTYPE html\n PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"\n\"http://www.w3c.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n"
    print "<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"ja\" lang=\"ja\">\n"
    print "<head>\n"
    print "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=euc-jp\" />\n"
    print "<title>テスト</title>\n"
    print "</head>\n"
    print "<body>\n"
    print "<form action=\"./evaluate.cgi\" method=\"POST\">\n"
  end

  # HTML問題部の出力
  def html_problem
    @params.each{|key, val|
      @t_db.create_doc(key)
      print "<fieldset>\n"
      print "<legend>#{key}</legend>\n"
      val.each{|v|
        @t_db.set_itemid(v)
        print "問題:" + @t_db.get_prob + "<br /><br />\n"
        print "選択肢:<br />\n"
        case selection_type(v)
        when "select_single_img" then
          print html_selection("radio", key, v)
        when "select_multi_img" then
          print html_selection("checkbox", key, v)
        when "select_single" then
          print html_selection("radio", key, v)
        when "select_multi" then
          print html_selection("checkbox", key, v)
        else
          print "<p>想定されていない問題形式</p>\n"
        end
      }
      print "<br />\n"
      print html_hints + "<br />\n"
      print "</fieldset>\n"
    }
  end

  # HTML選択肢部の出力
  def html_selection(itype, key, v)
    res_ary = @t_db.get_response
    str = ""
    cnt = 0
    res_ary.each{|s|
      str = str +  "<label><input type=\"#{itype}\" name=\"#{key}\" value=\"#{cnt}\" />#{res_ary[cnt]}</label>\n"
      cnt += 1
    }
    return str + "<label><input type=\"#{itype}\" name=\"#{key}\" value=\"null\" checked=\"checked\" />解からない</label><br />\n"
  end

  # HTMLヒント部の出力
  def html_hints
    return "ヒント:" + @t_db.get_hints
  end

  # HTML尾部の出力
  def html_end
    print "<br />\n"
    print "<input type=\"submit\" value=\"評価\" />\n"
    print "<input type=\"reset\" value=\"やり直し\" />\n"
    print "</form>\n"
    print "</body>\n"
    print "</html>\n"
  end    

  # 履歴作成
  def put_history
    @t_db.put_history
  end

end


st = Start.new
st.html_start
st.html_problem
st.html_end
st.put_history

#begin
#rescue StandardError
#  error_out()
#rescue ScriptError
#  error_out
#end

#x# CGIエラーメッセージ
#def error_out()
#  print "Content-Type:text/html\n\n"
#  $@.each {|x| print CGI.escapeHTML(x), "<br />\n"}
#end
