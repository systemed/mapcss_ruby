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
			if (@subject!='' and !subject_matches(entity)) then return false end
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
		
		private
		
		def subject_matches(entity)
			if entity.nil? then return @subject=='canvas' end
			if entity.type==@subject then return true end
			if @subject=='area' then return (entity is Way) &&  (entity.is_closed?) end
			if @subject=='line' then return (entity is Way) && !(entity.is_closed?) end
			return false
		end
		
	end
end
