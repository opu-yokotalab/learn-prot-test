#!/usr/bin/env ruby
# �����ƥ�ץ�ȥ�����
# ��������05/12/25
# ��������05/12/25
#

# QueryString����
require "cgi"

# ���ꥯ�饹
require "./test/test_db"

# ɾ�����饹
require "./test/evaluate"


class Evaluate_cgi

#include Test
#include Evalute

  # ���󥹥ȥ饯��
  def initialize
    # CGI
    qs = CGI.new
    @params = qs.params
#    @params = {"q1" => "0", "q2" => "1", "q3" => "2"}
    # ����
    @t_db = Test_db.new
    # ɾ��
    @eva = Evaluate.new
    # ɾ�����
    @result = Hash.new
    # ������¸��
    @his = Hash.new
    @his = @eva.get_history
  end

  # ����������Ȥ������ν���
  def selection_type(id)
    return @t_db.get_itemtype
  end

  # �������Ϥ�
  def eva_response
    @eva.response = @params
#    p @params
    @result = @eva.evaluate_response
#    p @result
  end
  
  # HTMLƬ���ν���
  def html_start
    print "Content-type: text/html\n\n"
    print "<?xml version=\"1.0\" encoding=\"euc-jp\" standalone=\"no\"?>\n"
    print "<!DOCTYPE html\n PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"\n\"http://www.w3c.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n"
    print "<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"ja\" lang=\"ja\">\n"
    print "<head>\n"
    print "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=euc-jp\" />\n"
    print "<title>ɾ��</title>\n"
    print "</head>\n"
    print "<body>\n"
  end

  # ����,�������ɽ��
  def crct_msg(key)
    if @result[key] == true then
      return "����"
    else
      return "������"
    end
  end
    

  # HTML�������ν���
  def html_problem
    @params.each{|key, val|
      @t_db.create_doc(key)
      print "<fieldset>\n"
      print "<legend>#{key}:#{crct_msg(key)}</legend>\n"
#      val.each{|v|
        @t_db.set_itemid(@his[key])
        print "����:" + @t_db.get_prob + "<br /><br />\n"
        print "�����:<br />\n" 
      print html_selection
 #     }
      print "<br />\n"
      print "���ʤ��β���:"
#      res_ary = @t_db.get_response
      val.each{|v|
        if v == "null" then
          print "̤����"
        else
          print "�����:" + (v.to_i + 1).to_s + " "
        end
      }
      print "<br />\n"
      print "����:"
      print html_correct
      print "<br /><br />\n"
      print html_explanation + "<br />\n"
      print "</fieldset>\n"
      print "<br />\n"
    }
  end

  # HTML��������ν���
  def html_selection
    res_ary = @t_db.get_response
    str = ""
    cnt = 0
    res_ary.each{|s|
      str = str +  "�����#{cnt + 1}:#{res_ary[cnt]} \n"
      cnt += 1
    }
    return str + "<br />\n"
  end

  # HTML�������ν���
  def html_correct
    res_ary = @t_db.get_response
    crct_ary = @t_db.get_correct
    str = ""
    crct_ary.each{|s|
      str = str +  "�����:#{s.to_i + 1} \n"
    }
    return str + "<br />\n"
  end

  # HTML���ν���
  def html_explanation
    return "����,����:" + @t_db.get_explanation
  end

  # HTML�����ν���
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
