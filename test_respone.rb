require 'net/http'
require "rexml/document"

include REXML

File.open("./examination_prot.xml") {|fp|
# �󔒂݂̂̃e�L�X�g�m�[�h�𖳎�
@doc = REXML::Document.new(fp, {:ignore_whitespace_nodes => :all})
}
lis = REXML::XPath.first(@doc,"//examination")


Net::HTTP.version_1_2   # ���܂��Ȃ�
Net::HTTP.start('localhost', 80) {|http|
# �ŏ��̏o��p�i�o��L�q�𑗐M�j
#  response = http.post('/~t_nishi/cgi-bin/prot_test/adel_exam.cgi',
#                       'mode=set&src=' + lis.to_s)

# ���O�]��
#  response = http.post('/~t_nishi/cgi-bin/prot_test/adel_exam.cgi',
#                       'mode=pre_evaluate&selected=q1_4_0&type=radio&value=0')

# �𓚊m��
#  response = http.post('/~t_nishi/cgi-bin/prot_test/adel_exam.cgi',
#                       'mode=evaluate&name=q1_4')

# ���ʎ擾
  response = http.post('/~t_nishi/cgi-bin/prot_test/adel_exam.cgi',
                       'mode=result')

  puts response.body
}

