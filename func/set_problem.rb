#!/usr/bin/env ruby
#
# ���ƥ��ȵ����ץ�ȥ�����
# ����⥸�塼��
# ������ 06/09/12
# �ǽ������� 06/09/12

# XML���
require "rexml/document"
# Ruby-xslt ���ץ��󥹥ȡ����
require 'xml/xslt'
# ʸ���������Ѵ�
require "kconv"
# ����DB����������
require "./func/test_db"
# ���Ͻ���ݻ�����ϥå��奯�饹
require "./func/OHash"
# ������ѥ⥸�塼��
require "./func/history"

module Set_problem

	include REXML

	# ����Υ���åե�
	def randArray(ary)
		ary.each_index{|i|
			j = rand(i+1)
			ary[i], ary[j] = ary[j], ary[i]
		}
		return ary
	end

	# �������礻���Ҥ��ᤷ�����XML������
	def get_xhtmlAll(inDoc)
		if inDoc == nil then # �ƤӽФ����Ҥ���äƤ��ʤ�
			return false
		end

		# ����DB���������ѥ��֥�������
		t_db = nil
		# �����ѥ��֥�������
		history = nil

		# document���֥�������
		tmpDoc = Document.new() # ���xml
		outDoc = Document.new() # ������xhtml

		#����DB
		t_db  = Test_db.new
		# ����⥸�塼��
		history = History.new("Test_id", "put")

		# ���ꤹ�������Ǽ������
		itemAry = Array.new
		# ��������ѥϥå���ʽ����
		tmpOHash = OHash.new
		# �ƥ��ȵ��ҵ�Ͽ������
		eAry = Array.new
		# ��������ѥϥå���ʷ���Ѥ�id�Τߡ�
		itemOHash = OHash.new
		# ������Ǽ�ꥹ��
		setAry = Array.new
		setOHash = OHash.new
		# �������������ʽ����
		tmpIdAry = Array.new

		# ���XML�롼����������
		tmpDoc.add(Element.new("exam"))
		tmpDoc.elements["exam"].add_attribute("id", "userID") # �ؽ���ID?������ͽ��

		# �����μ��������Ρ�
		ordering = get_examOrdering(inDoc)

		itmID = nil # �����ƥ�id

		get_groups(inDoc).each{|grps|
			# �ƽФ����Ҥ�group���Ǥ��Ȥ˽�����Ԥ�
			grpID = get_grpID(grps) # ���ꤷ��id�Υ��롼�פ�����
			grpMark = get_grpMark(grps) # ���롼�פ�����

			#������¸�ʥ��롼�ס�
			history.add_group(grpID, grpMark)
#puts "Group ID: " + grpID.to_s
			# ����DB�����귲ID�����
			t_db.create_doc(grpID.to_s)

			get_items(grpID, inDoc).each{|itms| # ���ٽ���ꥹ�Ȥ�����
#puts itms
				itmID = get_itmID(itms)
				itmType = get_itmType(itms)
				eAry << itmID
#puts itmType

				# id�ˤ�������ʬ����random��������, type���������, ����¾������id��
				case itmType
					when "random" then
						# ������������������
						tmpOHash["random"] = ""
						setOHash[itmID] = "random"
						setAry << "random"
					when "type" then
						# �������Ǥϥ�����
						# �����������������
						tmpOHash["type"]  = get_itemType(itms)
						setOHash[itmID] = "type"
						setAry << "type"
					else
						# id�������������
						tmpOHash["id"] = itmType
						setOHash[itmID] = "id"
						setAry << "id"
				end
			}

			# ���ꤷ��id������˳�Ǽ������ؤγ�Ǽ��Ϲ�θ���ʤ���
			# id����
			tmpOHash['id'].each{|lis|
#puts "ID: " + lis.to_s
				tmpIdAry << lis
				itemOHash['id'] = lis 
			}
			# ��������
			tmpOHash['type'].each{|lis|
				tmpType = t_db.get_IDbyType(lis, tmpIdAry)
#puts "tmpType: " + tmpType.to_s
				tmpIdAry << tmpType
				itemOHash['type'] = tmpType
			}
			# ���������
			tmpOHash['random'].each{|lis|
				tmpRandom = t_db.get_IDbyRand(tmpIdAry)
#puts "tmpRandom :" + tmpRandom
				tmpIdAry << tmpRandom
				itemOHash['random'] = tmpRandom
#p @t_db.get_IDbyRand(tmpIdAry)
			}

#print "tmpIdAry :"
#p tmpIdAry

			# tmpIdAry������˳��ꤷ�����Ƥ�id������
			# ����id���򸵤˼ºݤ���������
			# ���Τޤ�item���Ǥ򥳥ԡ��ǤϤʤ��ղþ���ɬ�ס������롼��ID��passing_grade���Ǥʤ�
			# �ϥå�������Υꥹ���ѥ�����
			# �����ܤθƽФ���
			cType = 0
			cRandom = 0
			cID = 0
			eCount = 0
			elem = Element.new
#p tmpOHash.keys
#p tmpOHash.values
#puts
#p itemOHash.keys
#p itemOHash.values
#p setAry
#p eAry

			# �����˽��äƽ������������
			setAry.each{|sary|
			#setOHash.keys.each{|key|
#puts "setOHash key: " + key
				#setOHash[key].each{|val|
#puts "setOHash value: " + val
				case sary
					when "id" then
						sItem_id = itemOHash['id'][cID].to_s
#puts "ID: " + grpID.to_s + "_" + sItem_id
						elem =  t_db.get_itembyID(sItem_id)
						elem.add_attribute("id", grpID.to_s + "_" + sItem_id)
						elem.add_attribute("type", get_typeValue(get_itmType(elem).to_s))
						# ������¸�������
						history.add_item(grpID, grpID.to_s + "_" + sItem_id)
						history.add_info2item(grpID, grpID.to_s + "_" + sItem_id, get_pgrade(grpID, eAry[eCount], inDoc))
						itemAry << elem
						cID = cID + 1
					when "type" then
						if itemOHash['type'][cType] != false then
							sItem_id = itemOHash['type'][cType].to_s
#puts "Type: " + grpID.to_s + "_" + sItem_id
							elem =  t_db.get_itembyID(sItem_id)
							elem.add_attribute("id", grpID.to_s + "_" + sItem_id)
							elem.add_attribute("type", get_typeValue(get_itmType(elem).to_s))
							# ������¸�������
							history.add_item(grpID, grpID.to_s + "_" + sItem_id)
							history.add_info2item(grpID, grpID.to_s + "_" + sItem_id, get_pgrade(grpID, eAry[eCount], inDoc))
							itemAry << elem
							cType = cType + 1
						end
					when "random" then
						if itemOHash['random'][cRandom] != false then
							sItem_id = itemOHash['random'][cRandom].to_s
#puts "Random: " + grpID.to_s + "_" + sItem_id
							elem =  t_db.get_itembyID(sItem_id)
							elem.add_attribute("id", grpID.to_s + "_" + sItem_id)
							elem.add_attribute("type", get_typeValue(get_itmType(elem).to_s))
							# ������¸�������
							history.add_item(grpID, grpID.to_s + "_" + sItem_id)
							history.add_info2item(grpID, grpID.to_s + "_" + sItem_id, get_pgrade(grpID, eAry[eCount] ,inDoc))
							itemAry << elem
							cRandom = cRandom + 1
						end
				end
				#}
				eCount = eCount + 1
#puts elem
			}

# for Debug
#puts tmpIdAry.join(', ')
#p tmpOHash.keys
#p tmpOHash.values
#puts
#p itemOHash.keys
#p itemOHash.values
#puts
#p setOHash.keys
#p setOHash.values
#puts setAry.join(', ')
#puts

			tmpOHash.clear
			itemOHash.clear
			setAry.clear
			eAry.clear
			setOHash.clear
			tmpIdAry.clear
		}


		# ����礬random����ʤ�����ޥ���
		if ordering == "random"  then
			itemAry = randArray(itemAry)
		end
#puts @history.printHistory
#puts itemAry.join(', ')
#p itemAry.join(', ')

		# ���XML������
		itemAry.each{|i|
			tmpDoc.elements["exam"].add_element(i)
		}
#puts @tmpDoc.to_s.kconv(Kconv::EUC, Kconv::UTF8)
#puts "tmpDoc"
#puts tmpDoc
#puts 
		# ���������
		# make_history

		# xslt���֥�������
		xslt = XML::XSLT.new()
		xslt.xml = tmpDoc
		x = REXML::Document.new File.open( "./test.xsl" )
		xslt.xsl = x
		out = xslt.serve() # String���֥�������

		outDoc = REXML::Document.new(out)
		#puts @outDoc.class
#puts @outDoc
#puts @tmpDoc

		# �������¸������
		history.saveHistory("./func/history.xml")

		#puts @outDoc.get_elements("//body/node()")
		# body���ǰʲ����֤�
		return outDoc.get_elements("//body/node()")

		#return @outDoc
	end


	# examination���ǰʲ���group���Ǥμ���
	def get_groups(inDoc)
		return inDoc.get_elements("/examination/group")
	end


	# �����μ��������Ρ�
	def get_examOrdering(inDoc)
		return REXML::XPath.first(inDoc, "/examination").attributes["ordering"]
	end


	# group[@id=gID]�ʲ���item���Ǥμ���
	def get_items(gID, inDoc)
		return inDoc.get_elements("/examination/group[@id = \"" + gID.to_s + "\"]/item")
	end


	# ���ꤷ��item���ǰʲ���selection_type���ǤΥƥ����ȥΡ��ɤμ���
	# �������λ��ͤǤϡ�id°����random��type���դ˷���Ǥ��ʤ��Τǡ�
	# ����ƥ����ȥΡ���Ū��Elements���Ǥ�����˼�롣
	def get_itemType(item_node)
		return item_node.text("selection_type")
	end


	# group��Element�����Ǥλ��ĥ��롼��id�����
	def get_grpID(grp)
		return grp.attributes["id"]
	end


	# group��Element�����Ǥλ��ĥ��롼�פ����������
	def get_grpMark(grp)
		return grp.attributes["mark"].to_s
	end


	# item��Element�����Ǥλ���type°�������
	def get_itmType(itm)
		return itm.attributes["type"].to_s
	end


	# item��Element�����Ǥλ���id°�������
	def get_itmID(itm)
		return itm.attributes["id"]
	end


	# �ƤӽФ����Ҥ���passing_grade���ͤ����
	def get_pgrade(grpID, itmID, inDoc)
	#puts grpID
	#puts itmID
	#puts inDoc.get_elements("/examination/group[@id = \"" + grpID + "\"]/item[@id=\"" + itmID + "\"]/passing_grade")[0]
		return inDoc.get_elements("/examination/group[@id = \"" + grpID + "\"]/item[@id=\"" + itmID + "\"]/passing_grade")[0]
	end


	# �����������input���Ǥ�type°���ͤ����
	def get_typeValue(type)
		inpType = create_doc4itype

		typeAry = Array.new
		typeAry = inpType.get_elements("/input_type/input/object[@type=\"" + type + "\"]")
#puts type
#puts typeAry[0].parent.attribute("type")
		return typeAry[0].parent.attribute("type")
	end


	# input���Ǥ�type°���ͤ�Ͽ����xmlʸ����ɤ߹���
	def create_doc4itype
		inpType = nil
		File.open("./func/input_type.xml") {|fp|
		# ����ΤߤΥƥ����ȥΡ��ɤ�̵��
		inpType = REXML::Document.new(fp, {:ignore_whitespace_nodes => :all})
		}
		return inpType
	end
end