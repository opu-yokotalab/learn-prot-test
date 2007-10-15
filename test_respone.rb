require 'net/http'
require "rexml/document"

include REXML

File.open("./examination_prot.xml") {|fp|
# 空白のみのテキストノードを無視
@doc = REXML::Document.new(fp, {:ignore_whitespace_nodes => :all})
}
lis = REXML::XPath.first(@doc,"//examination")


Net::HTTP.version_1_2   # おまじない
Net::HTTP.start('localhost', 80) {|http|
# 最初の出題用（出題記述を送信）
#  response = http.post('/~t_nishi/cgi-bin/prot_test/adel_exam.cgi',
#                       'mode=set&src=' + lis.to_s)

# 事前評価
#  response = http.post('/~t_nishi/cgi-bin/prot_test/adel_exam.cgi',
#                       'mode=pre_evaluate&selected=q1_4_0&type=radio&value=0')

# 解答確定
#  response = http.post('/~t_nishi/cgi-bin/prot_test/adel_exam.cgi',
#                       'mode=evaluate&name=q1_4')

# 結果取得
  response = http.post('/~t_nishi/cgi-bin/prot_test/adel_exam.cgi',
                       'mode=result')

  puts response.body
}

