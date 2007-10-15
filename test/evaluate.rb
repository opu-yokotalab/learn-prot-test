#!/usr/bin/env ruby
#
# 解答評価プログラム(仮)
# ver 0.0.1
# 作成日 05/12/21
# 最終更新日 05/12/21

  
  # 出題クラス
  require "./test/test_db"
  
  # 履歴クラス
  require "./test/history"
  
  class Evaluate
    
    # コンストラクタ
    def initialize
      # 出題クラス
      @t_db = Test_db.new
      # 履歴クラス
      @his_mod = History.new
      # 履歴
      @his = Hash.new
      # 解答格納用
      @response = Hash.new
      # 評価結果格納用
      @result = Hash.new
    end
    
    # 解答を受け取る
    def response=(value)
      @response = value
    end
    
    # 出題履歴の取得
    def get_history
      @his = @his_mod.history_gets
      return @his
    end
        
    # 解答の評価
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
    
    # 正解と解答の比較
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
  


# 試験動作用
if __FILE__ == $0 then
  eva = Evaluate.new
  p eva.get_history
  eva.response = {"q1" => ["0","1","2"], "q2" => ["2","3","4"], "q3" => ["0","1"]}
  r = Hash.new
  r = eva.evaluate_response
  p r
end
