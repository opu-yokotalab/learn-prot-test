#!/usr/bin/env ruby
#
# ����ץ����
#
# ������ 05/12/28
# �ǽ������� 05/12/28


#class History
  class Hhistory

    # ���󥹥ȥ饯��
    def initialize
      @his = Hash.new
    end

    # his����
    def his
      return @his
    end

    # his�ѹ�
    def his=(value)
      @his = value
    end

    # �����ɤ߹���
    def history_gets
#      print File.expand_path("./test/history.txt")
      File.open(File.expand_path("./func/history.txt"),"r") {|fp|
        return record2hash(fp.gets.chomp!)
      }
    end

    # ����񤭹���(��񤭥⡼��)
    def history_puts
#      print File.expand_path("./test/history.txt")
      File.open(File.expand_path("./func/history.txt"),"w") {|fp|
        fp.puts hash2record
      }
    end

    # Hash -> ��Ͽ�������Ѵ�
    def hash2record
      str = String.new
      @his.each {|key, val|
        #val.each {|v|
          str = str + key.to_s + ":" + val.to_s + ","
        #}
      }
      return str.chop!
    end

    # ��Ͽ���� -> Hash���Ѵ�
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


# ư��
if __FILE__ == $0 then
  prot = History.new
  prot.his = {"q1" => "0", "q2" => "1", "q3" => "2"}
  prot.history_puts
#  print prot.hash2record + "\n"
#  p prot.record2hash("q1:2,q2:0,q3:1,")
#  print "\n"

#  p prot.history_gets
end
