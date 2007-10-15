#!/usr/bin/env ruby
#
# ����ɾ���ץ����

# REXML
require "rexml/document"
# ����DB���饹
require "./func/test_db"
# ���򥯥饹
require "./func/history"
# Ruby-xslt ���ץ��󥹥ȡ����
require 'xml/xslt'

module Evaluate

	include REXML

	# �ץ�ɾ��
	def pre_evaluate(params)
		# �ְ㤨�ƸƤФ줤�Ƥ��ʤ���
		if params["mode"].to_s != "pre_evaluate" then
puts "mode is false."
			return false
		end

		# ���������ˤ�������ʬ��
		qs = params["type"].to_s
		eValue = nil
		case qs
			when "radio" then
				eValue = params["value"].to_s
				evaluate_radio(params)
			when "checkbox" then
				eValue = params["checked"].to_s
				return "non"
			when "text" then
				eValue = params["value"].to_s
				return "non"
			else # ����¾ or ��ĥ��
				eValue = "other"
				return "non"
		end

	end

	# ɾ����radio�ѡ�
	def evaluate_radio(params)
		# ����DB����������
		t_db = Test_db.new
		# ����⥸�塼��
		history = History.new("Test_id", "get")

		# �����
		correct = 0
		# �������
		incorrect = 0

		# ������ɲä�����ʬ��
		elem = Element.new("evaluate")

		# eValue����������
		# �ץ�ɾ���η�̤���˽񤭹���
		sAry = Array.new
		# selected���ͤ򥰥롼��ID������ID��Value��ʬ��
		sAry = params["selected"].to_s.split("_")
	
		# ���롼��ID������ID�򸵤�����DB���鳺��������������

		# ����DB�򳫤�
		t_db.create_doc(sAry[0])

		# evaluate°���ͤ��Ѥ��Ʒ׻�
		cAry = Array.new
		cAry = t_db.get_correct(sAry[1]).to_s.split(",")

		# ɾ��
		if cAry.include?(params["value"].to_s) then
			correct += 1
		else
			incorrect += 1
		end

		# ���������������������Ͽ
		cNode = Element.new("correct")
		cNode.add_text(correct.to_s)
		cNode.add_attribute("weight", t_db.get_weight(sAry[1],"correct"))

		iNode = Element.new("incorrect")
		iNode.add_text(incorrect.to_s)
		iNode.add_attribute("weight", t_db.get_weight(sAry[1],"incorrect"))

		elem.add_element(cNode)
		elem.add_element(iNode)

		# ���������ݥ����
		pNode = Element.new("score")
		point = (correct.to_i * t_db.get_weight(sAry[1],"correct").to_i) + (incorrect.to_i * t_db.get_weight(sAry[1],"incorrect").to_i)
		pNode.add_text(point.to_s)

		elem.add_element(pNode)
#puts elem

		# �ؽ��Ԥ�����������(Value)�Ȥ��η�̡�������������ˤ���˽񤭹���
#history.printHistory
#puts sAry[0] + "_" + sAry[1]
		history.del_evaluate(sAry[0], sAry[0] + "_" + sAry[1])
#history.printHistory
		history.add_info2item(sAry[0], sAry[0] + "_" + sAry[1], elem)
		history.saveHistory("./func/history.xml")
#puts "after"
#puts history.printHistory

		return point.to_s
#		return cAry.include?(params["value"].to_s)
	end


	# ��������
	def evaluate(params)
		# ����DB����������
		t_db = Test_db.new
		# ����⥸�塼��
		history = History.new("Test_id", "get")

		# ����
		sAry = Array.new
		# selected���ͤ򥰥롼��ID������ID��Value��ʬ��
		sAry = params["name"].to_s.split("_")

		if sAry == nil then
			return false
		end
#puts sAry[0].to_s + "_" + sAry[1].to_s
		# ����DB�򳫤�
		t_db.create_doc(sAry[0].to_s)

		# ����Ȥʤ�����
		tdbScore =  t_db.get_score(sAry[1].to_s)

		# ɾ���������
		hisScore =  history.get_score(sAry[0].to_s, sAry[0].to_s + "_" + sAry[1].to_s)
#puts tdbScore + " , " + hisScore

		# ɾ����̤��֤���
		res = "false"

		if tdbScore.to_i <= hisScore.to_i then # ���ͤ�Ķ���� => ����
			pnt = t_db.get_point(sAry[1].to_s)
			history.add_evaluated(sAry[0].to_s, sAry[0].to_s + "_" + sAry[1].to_s, pnt, "true")
			res = "true"

		else
			pnt = 0
			history.add_evaluated(sAry[0].to_s, sAry[0].to_s + "_" + sAry[1].to_s, pnt, "false")
			res = "false"
		end

		history.saveHistory("./func/history.xml")
#puts res.to_s

		# �����������ؤ�
		elem = t_db.get_itembyID(sAry[1])
		elem.add_attribute("id", sAry[0] + "_" + sAry[1])
		elem.add_attribute("evaluate", res)
		dElem = Document.new()
		dElem.add(elem)
#puts dElem

		# xslt���֥�������
		xslt = XML::XSLT.new()
		xslt.xml = dElem
		xslt.xsl = REXML::Document.new File.open( "./evaluate.xsl" )
		out = xslt.serve() # String���֥�������
		outDoc = REXML::Document.new(out)

		if res == "true" then
			tElem = outDoc.get_elements("/div/div/h2")[0]
			str = "����"

		else
			tElem = outDoc.get_elements("/div/div/h2")[0]
			str = "������..."
		end
		tElem.add_text(Kconv.kconv(str, Kconv::UTF8))
#puts outDoc
#puts outDoc.get_elements("/div[@id=\"item_" + sAry[0] + "_" + sAry[1] + "\"]").to_s
		return outDoc.get_elements("/div[@id=\"item_" + sAry[0] + "_" + sAry[1] + "\"]").to_s

	end

	# ���롼��ñ�̤�ɾ��
	def grp_evaluate
#puts "grp: "
		# ����⥸�塼��
		history = History.new("Test_id", "get")

		tmpHash = Hash.new
		tmpScore = nil
		tmpInt = 0
		flg = true
#history.printHistory
#puts history.get_groups().class
		history.get_groups().each{|grps|
		tmpInt = 0
		flg = true
#puts grps
#puts grps.attribute("id").to_s
		tmpHash[grps.attribute("id").to_s] = nil
			history.get_items(grps.attribute("id").to_s).each{|itms|
				tmpScore = itms.attribute("score")
#puts tmpScore
				if tmpScore != nil then
					tmpInt = tmpInt + tmpScore.value.to_i
					#tmpHash[grps.attribute("id").to_s] = tmpInt
				else
					
					# 1�ս�Ǥ�̤ɾ��
					#flg = false
					tmpInt = -1
					break
				end
			}
#puts tmpInt
#puts flg
			#if flg then
				tmpHash[grps.attribute("id").to_s] = tmpInt
			#end
		}
		return tmpHash
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
