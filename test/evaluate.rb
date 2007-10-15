#!/usr/bin/env ruby
#
# ����ɾ���ץ����(��)
# ver 0.0.1
# ������ 05/12/21
# �ǽ������� 05/12/21

  
  # ���ꥯ�饹
  require "./test/test_db"
  
  # ���򥯥饹
  require "./test/history"
  
  class Evaluate
    
    # ���󥹥ȥ饯��
    def initialize
      # ���ꥯ�饹
      @t_db = Test_db.new
      # ���򥯥饹
      @his_mod = History.new
      # ����
      @his = Hash.new
      # ������Ǽ��
      @response = Hash.new
      # ɾ����̳�Ǽ��
      @result = Hash.new
    end
    
    # ������������
    def response=(value)
      @response = value
    end
    
    # ��������μ���
    def get_history
      @his = @his_mod.history_gets
      return @his
    end
        
    # ������ɾ��
    def evaluate_response
      crct_ary = Array.new
      @response.each{|key, val|
        @t_db.create_doc(key)
        @t_db.set_itemid(@his[key])
        crct_ary = @t_db.get_correct()
#        val.each{|v|
#          v_ary = Array.new
#          v_ary = v.split(",")
          @result.store(key, compare_response?(val, crct_ary))
#        }
      }
      return @result
    end
    
    # ����Ȳ��������
    def compare_response?(v_ary, crct_ary)
      if v_ary.size != crct_ary.size then
        return false
      end
      flag = 1
      flag_ary = Array.new
      cnt = 0
      v_ary.each{|v_a|
        crct_ary.each{|c|
#          print "v_a:" + v_a + ",c:" + c + "\n"
          if v_a == c then
            flag *= 0
            break
          else
            flag *= 1
          end
        }
#        print "flag:" + flag.to_s + "\n"
        flag_ary[cnt] = flag
        flag = 1
        cnt += 1
      }
      flag = 1
      flag_ary.each{|fa|
        if fa == 1 then
          flag = 0
        end 
      }
      if flag == 1 then
        return true
      else
        return false
      end
    end   
    
  end
  


# �ư����
if __FILE__ == $0 then
  eva = Evaluate.new
  p eva.get_history
  eva.response = {"q1" => ["0","1","2"], "q2" => ["2","3","4"], "q3" => ["0","1"]}
  r = Hash.new
  r = eva.evaluate_response
  p r
end
