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
			@shapestyles.each_value do |ss|
				if ss.defined('fill_color') or ss.defined('fill_image') then return true end
			end
			false
		end
		
		def layer_override
			@shapestyles.each_value do |ss|
				if ss.defined('layer') then return ss.get('layer')
				end
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
			"StyleList: SS #{@shapestyles} TS #{@textstyles} PS #{@pointstyles}: maxwidth #{@maxwidth}, valid at #{@validat}: subparts #{@subparts}\n"
		end
			
	end
end
