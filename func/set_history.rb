#!/usr/bin/env ruby
#
# ��������ѥ⥸�塼��

# XML���
require "rexml/document"

module Set_history

	include REXML

	# ���˥��롼��������ɲ�
	def add_grp(grpID,grpMark, tmpHis)
		tmpelem = REXML::Element.new("group")
		tmpelem.add_attribute("id", grpID)
		tmpelem.add_attribute("mark", grpMark)
		
		tmpHis.elements["exam"].add_element(tmpelem) # group���Ǥ��ɲ�
		return tmpHis
	end

	# ���ꤷ��item��������ɲ�
	def add_itm(grpID, itmID, tmpHis)
		tmpelem = Element.new("item")
		tmpelem.add_attribute("id", itmID)

		REXML::XPath.first(tmpHis, "//exam/group[@id=\"" + grpID + "\"]").add_element(tmpelem)
		#puts tmpHis.elements["exam"].elements["group"].attributes["id"].class#add_element(tmpelem)
		return tmpHis
	end

	# item��������ղþ����Ͽ
	def add_inf2item(grpID, itmID, elem, tmpHis)
	#puts elem
	#puts grpID
	#puts itmID
	#puts tmpHis
		REXML::XPath.first(tmpHis, "//exam/group[@id=\"" + grpID + "\"]/item[@id=\"" + itmID + "\"]").add_element(elem)
		return tmpHis
	end

	# ������evaluate���Ǥ���
	def delete_evaluate(grpID, itmID, tmpHis)
		tmpElm = tmpHis.get_elements("//exam/group[@id=\"" + grpID + "\"]/item[@id=\"" + itmID + "\"]")[0]
		tmpElm.delete_element("evaluate")
	end

	# ������ɾ�����������������
	def get_score_(grpID, itmID, tmpHis)
		tmpElem = tmpHis.get_elements("//exam/group[@id=\"" + grpID + "\"]/item[@id=\"" + itmID + "\"]/evaluate/score")[0]
		return tmpElem.text
	end

	# ɾ����̤��ɲ�
	def add_evaluated_(grpID, itmID , score, checked, tmpHis)
		tmpElem = tmpHis.get_elements("//exam/group[@id=\"" + grpID + "\"]/item[@id=\"" + itmID + "\"]")[0]
		tmpElem.add_attribute("score", score)
		tmpElem.add_attribute("checked", checked)
		return checked
	end

	# item���Ƿ�����
	def get_items_(grpID, tmpHis)
		return tmpHis.get_elements("//exam/group[@id=\"" + grpID + "\"]/item")
	end

	# group���Ǥ�Ȥ�
	def get_groups_(tmpHis)
		return tmpHis.get_elements("//exam/group")
	end

	# �������¸
	def save(filename, tmpHis)
		File.open(filename, "w"){|fp|
			fp.puts tmpHis
		}
	end

# �����ν�̤����

	# �ե����뤫��Document���֥������Ȥ�����
	def create_log()
		File.open("/func/history.xml") {|fp|
			# ����ΤߤΥƥ����ȥΡ��ɤ�̵��
			doc = REXML::Document.new(fp, {:ignore_whitespace_nodes => :all})
		}
		return doc
	end

	# ��������¸�ߤ��Ƥ��뤫
	def logExsist?
		return FileTest.exsist?("./func/history.xml")
	end

	# ����˥桼����ID��¸�ߤ��뤫
	def uidExsist?(u_id, tmpHis)
		if tmpHis.element["history"].attribute[u_id] == nil then
			return false
		else
			return true
		end
	end

	# �ؽ���ID�Υ������
	def makelog4uid(u_id, tmpHis)
		tmpHis.elements["history_log"].add_attribute("uid", u_id) # �ؽ���ID?������ͽ��
	end

	# ���ꤷ���桼��ID�Υ����֤�
	def get_usrLog(u_id)
		@exam_log = @His.get_elements("/history_log[@uid = \"" + @uid + "\"]")[0]
	end
end