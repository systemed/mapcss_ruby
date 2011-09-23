module StyleParser
	class Rule

		attr_accessor	:conditions, :isand, :minzoom, :maxzoom
		
		def initialize(subject)
			@subject=subject
			@conditions=[]
			@minzoom=0
			@maxzoom=255
			@isand=true
		end
		
		def test(entity,tags,zoom)
			if (@subject!='' and entity.type!=@subject) then return false end
			if (zoom<@minzoom or zoom>@maxzoom) then return false end
			
			v=true
			i=0
			@conditions.each do |condition|
				r=condition.test(tags)
				if i==0
					v=r
				elsif @isand
					v=v && r
				else
					v=v || r
				end
				i+=1
			end
			v
		end
		
	end
end
