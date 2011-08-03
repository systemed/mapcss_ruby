module StyleParser
	class Condition

		def initialize(type,param1,param2=nil)
			@type=type
			@param1=param1
			@param2=param2
		end
		
		def test(tags)
			case @type
				when 'eq'
					return tags[@param1]==@param2
				when 'ne'
					return tags[@param1]!=@param2
				when 'regex'
					return tags[@param1]=~Regexp.new(@param2)
				when 'true'
					return (tags[@param1]=='true' or tags[@param1]=='yes' or tags[@param1]=='1')
				when 'false'
					return (tags[@param1]=='false' or tags[@param1]=='no' or tags[@param1]=='0')
				when 'set'
					return (tags[@param1] and tags[@param1]!='')
				when 'unset'
					return (tags[@param1].nil? or tags[@param1]=='')
				when '<'
					return tags[@param1].to_f <  @param2.to_f
				when '<='
					return tags[@param1].to_f <= @param2.to_f
				when '>'
					return tags[@param1].to_f >  @param2.to_f
				when '>='
					return tags[@param1].to_f >= @param2.to_f
			end
			false
		end

	end
end
