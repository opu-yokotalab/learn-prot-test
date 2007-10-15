#!/usr/bin/env ruby
#
# ���򥯥饹

# XML���
require "rexml/document"
# ʸ���������Ѵ�
require "kconv"
# ���XML���⥸�塼��
require "./func/set_history"

class History

	include REXML
	include Set_history

	# ���饹�ѿ�
	@His = nil # ����Document���֥�������
	#@exam_log = nil # �ؽ���IDñ�̤Υ���Element���֥�������
	#@uid = nil # �ؽ���ID

	# ���󥹥ȥ饯��
	def initialize(t_id, mode)
	# ����¸�ߤ��Ƥ����餽����ɤ߹��ࡣ̵����п���������
#puts "mode: " + mode
		if File.exist?("./func/history.xml") then
			if mode == "get" then
				@His = create_doc("./func/history.xml")
			elsif mode == "put" then
				# �롼�����ǿ�������
				create_root(t_id) # ����
			end
		else
			create_root(t_id) #�롼�����Ǻ���
		end
	end

	# ������ɹ���
	def create_doc(filename)
		doc = nil
		File.open(filename) {|fp|
		# ����ΤߤΥƥ����ȥΡ��ɤ�̵��
		doc = REXML::Document.new(fp, {:ignore_whitespace_nodes => :all})
		}
		return doc
	end

	# �롼�����Ǥκ���
	def create_root(t_id)
		@His = Document.new()
		@His.add(Element.new("exam"))
		@His.elements["exam"].add_attribute("id", t_id)
	end

	# ���롼�פ������ɲ�
	def add_group(grpID, grpMark)
		@His = add_grp(grpID,grpMark, @His)
		return @His
	end

	# ����������ɲ�
	def add_item(grpID, itmID)
		@His = add_itm(grpID, itmID, @His)
		return @His
	end

	# �����������ղþ����Ͽ
	def add_info2item(grpID, itmID, elem)
		@His = add_inf2item(grpID, itmID, elem, @His)
		return @His
	end

	# item���Ǥ�score°����ɾ����̡ˡ�check°��������������Υե饰�ˤ��ղ�
	def add_evaluated(grpID, itmID, score, checked)
		return add_evaluated_(grpID, itmID, score, checked ,@His)
	end

	# evaluate���Ǥκ��
	def del_evaluate(grpID, itmID)
		delete_evaluate(grpID, itmID, @His)
	end

	# ������ɾ�����������������
	def get_score(grpID, itmID)
		return get_score_(grpID, itmID, @His)
	end

	# item���Ǥ���
	def get_items(grpID)
		return get_items_(grpID, @His)
	end

	# group���Ǥ�Ȥ�
	def get_groups()
		return get_groups_(@His)
	end

	# �������¸
	def saveHistory(filename)
		save(filename, @His)
	end

	# �����ɽ����for Debug��
	def printHistory
		puts @His
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
