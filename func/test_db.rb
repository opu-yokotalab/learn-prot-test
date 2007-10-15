#!/usr/bin/env ruby
#
# �ƥ��ȵ����ץ�ȥ�����
# ����ƽ��ѥ��饹

# XML���
require "rexml/document"
# ʸ���������Ѵ�
require "kconv"
# ����
#require "./test/history"

class Test_db

  # XML���
  include REXML

	def initialize()
		@doc = nil
		#create_doc(filename)
	end

	def create_doc(filename)
		File.open("./db/" + filename + ".xml") {|fp|
			# ����ΤߤΥƥ����ȥΡ��ɤ�̵��
			@doc = REXML::Document.new(fp, {:ignore_whitespace_nodes => :all})
		}
	end

	def get_itembyID(item_id)
		# �֤��ͤ�Array���饹�ʤΤǡ�REXML::Element�ˤ��뤿��˺ǽ�����Ǥ�������
		e_ary = @doc.get_elements("/problem_set/item[@id=\"" + item_id + "\"]")
		return e_ary[0]
	end

#	def get_itembyType(item_type, ary)
# ��
#		elems = @doc.elements.to_a("/problem_set/item[@type=\"" + item_type + "\"]").collect
#		r_num = rand(elems.length)
#		
#		return elems[r_num]
#	end

	def get_IDbyRand(ary)
		attrTmpAry = Array.new
		# group���item���ǿ�����������1�ķ���
		elems =  @doc.elements.to_a("/problem_set/item").collect

		# ��������item���Ǥ�id�������
		elems.each{|e|
			attrTmpAry << e.attributes["id"]
		}

		# ���˷��ꤵ�줿id���Ⱥ����롣���Ǥ�̵����н����;�Ϥʤ�
		attrTmpAry = attrTmpAry - ary
		if attrTmpAry.length == 0 then
			return false
		end
#puts "Length: " + attrTmpAry.length.to_s
		r_num = rand(attrTmpAry.length)
#puts "r_num: " + r_num.to_s
#print "attrTmpAry: "
#p attrTmpAry
#print "ary: "
#p ary
		return attrTmpAry[r_num]
# ��
#		# �֤��ͤ�Array���饹�ʤΤǡ�REXML::Element�ˤ��뤿��˺ǽ�����Ǥ�������
#		e_ary = @doc.get_elements("/problem_set/item[@id=\"" + r_num.to_s + "\"]")
#		return e_ary[0]
	end

	def get_IDbyType(item_type, ary)
		attrTmpAry = Array.new
		elems = @doc.get_elements("/problem_set/item[@type=\"" + item_type + "\"]")
		# ��������item���Ǥ�id�������
		elems.each{|e|
			attrTmpAry << e.attributes["id"]
		}

		# ���˷��ꤵ�줿id���Ⱥ����롣���Ǥ�̵����н����;�Ϥʤ�
		attrTmpAry = attrTmpAry - ary
		if attrTmpAry.length == 0 then
			return false
		end
#puts "Length: " + attrTmpAry.length.to_s
		r_num = rand(attrTmpAry.length)
#puts "r_num: " + r_num.to_s
		return attrTmpAry[r_num]
	end

	def get_evaluate(item_id)
		return @doc.get_elements("/problem_set/item[@id=\"" + item_id + "\"]/evaluate")[0]
	end

	def get_correct(item_id)
		return get_evaluate(item_id).elements["correct"].attribute("id")
	end

	def get_score(item_id)
		tmpElem = get_evaluate(item_id).get_elements("./score")[0]
		return tmpElem.text
	end

	def get_weight(item_id, mode)
		return get_evaluate(item_id).elements["weight"].attribute(mode).to_s
	end

	def get_point(item_id)
		tmpElem = get_evaluate(item_id).get_elements("./point")[0]
		return tmpElem.text
	end

end


# �ư����
if __FILE__ == $0 then
	prot = Test_db.new("q1")
	#prot.create_doc("q1")
	puts prot.get_itembyID("0")
end
