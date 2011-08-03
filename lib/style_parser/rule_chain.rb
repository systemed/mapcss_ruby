module StyleParser
	class RuleChain

		attr_accessor	:rules, :subpart
		
		def initialize
			@rules=[]
			@subpart='default'
		end
		
		def test(pos, entity, tags, zoom)
			if @rules.length==0 then return false end
			if pos==-1 then pos=@rules.length-1 end
			
			r=@rules[pos]
			unless (r.test(entity, tags, zoom)) then return false end
			if pos==0 then return true end
				
			Dictionary.instance.parent_objects(entity).each do |p|
				if (test(pos-1, p, p.tags, zoom)) then return true end
			end
			return false
		end
		
		def set_subpart(s)
			@subpart = (s=='') ? 'default' : s
		end
		
		def add_rule(e='')
			@rules.push(Rule.new(e))
		end
		
		def add_condition_to_last(c)
			@rules[@rules.length-1].conditions.push(c)
		end
		
		def add_zoom_to_last(z1,z2)
			@rules[@rules.length-1].minzoom=z1
			@rules[@rules.length-1].maxzoom=z2
		end

		def to_s
			"[RuleChain #{@subpart}: #{@rules}]"
		end

	end
end
