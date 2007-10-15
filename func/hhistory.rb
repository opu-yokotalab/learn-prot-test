#!/usr/bin/env ruby
#
# 履歴プログラム
#
# 作成日 05/12/28
# 最終更新日 05/12/28


#class History
  class Hhistory

    # コンストラクタ
    def initialize
      @his = Hash.new
    end

    # his参照
    def his
      return @his
    end

    # his変更
    def his=(value)
      @his = value
    end

    # 履歴読み込み
    def history_gets
#      print File.expand_path("./test/history.txt")
      File.open(File.expand_path("./func/history.txt"),"r") {|fp|
        return record2hash(fp.gets.chomp!)
      }
    end

    # 履歴書き込み(上書きモード)
    def history_puts
#      print File.expand_path("./test/history.txt")
      File.open(File.expand_path("./func/history.txt"),"w") {|fp|
        fp.puts hash2record
      }
    end

    # Hash -> 記録形式の変換
    def hash2record
      str = String.new
      @his.each {|key, val|
        #val.each {|v|
          str = str + key.to_s + ":" + val.to_s + ","
        #}
      }
      return str.chop!
    end

    # 記録形式 -> Hashの変換
    def record2hash(str)
      h = Hash.new
      sm_ary = str.split(",")
      sm_ary.each {|s|
        cm_ary = s.split(":")
        h.store(cm_ary[0],cm_ary[1])
      }
      return h
    end

  end


# 動作試験
if __FILE__ == $0 then
  prot = History.new
  prot.his = {"q1" => "0", "q2" => "1", "q3" => "2"}
  prot.history_puts
#  print prot.hash2record + "\n"
#  p prot.record2hash("q1:2,q2:0,q3:1,")
#  print "\n"

#  p prot.history_gets
end
