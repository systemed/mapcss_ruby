module StyleParser
	class StyleList

		attr_accessor	:shapestyles, :textstyles, :pointstyles, :shieldstyles, :maxwidth, :subparts, :validat
		
		def initialize
			@shapestyles={}
			@textstyles={}
			@pointstyles={}
			@shieldstyles={}
			@maxwidth=0
			@subparts=[]
			@validat=-1
		end
		
		def has_styles
			return !(@shapestyles.empty? and @textstyles.empty? and @pointstyles.empty? and @shieldstyles.empty?)
		end
		
		def has_fills
			@shapestyles.each do |ss|
				if (ss.properties['fill_color'] or ss.properties['fill_image']) then return true end
			end
			false
		end
		
		def layer_override
			@shapestyles.each do |ss|
				if ss.properties['layer'] then return ss.properties['layer'] end
			end
			nil
		end
		
		def add_subpart(s)
			unless @subparts.index(s)
				@subparts.push(s)
			end
		end
		
		def is_valid_at(zoom)
			(@validat==-1 || @validat==zoom)
		end
		
		def to_s
			"shapestyles: #{@shapestyles}\ntextstyles: #{@textstyles}\npointstyles: #{@pointstyles}\nshieldstyles: #{@shieldstyles}\nmaxwidth #{@maxwidth}, valid at #{@validat}\nsubparts: #{@subparts}"
		end
			
	end
end
