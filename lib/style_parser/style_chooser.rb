module StyleParser
	class StyleChooser

		attr_accessor	:rulechains, :styles, :zoomspecific
		
		def initialize
			@rulechains=[RuleChain.new()]
			@rcpos=0
			@styles=[]
		end
		
		def currentchain
			return @rulechains[@rcpos]
		end
		
		def update_styles(entity, tags, sl, imagewidths, zoom)
			if (@zoomspecific) then sl.validat=zoom end

			@rulechains.each do |c|
				if (c.test(-1,entity,tags,zoom))
					sl.add_subpart(c.subpart)
					@styles.each do |r|
						if (r.instance_of? ShapeStyle)
							a=sl.shapestyles
							if r.defined('width') then maxwidth(tags,r,'width') end
						elsif (r.instance_of? ShieldStyle)
							a=sl.shieldstyles
						elsif (r.instance_of? TextStyle)
							a=sl.textstyles
						elsif (r.instance_of? PointStyle)
							a=sl.pointstyles
							w=0
							if r.defined('icon_width') then maxwidth(tags,r,'icon_width') end
# ** FIXME - imagewidths:::	elsif r.defined('icon_image') and imagewidths[r.get('icon_image')]
#								w=imagewidths[r.get('icon_image')]
#							end
						elsif (r.instance_of? InstructionStyle)
							if r.breaker then return end
# ** FIXME - settags:::     if r.settags then r.settags.each { |k,v| tags[k]=v } end
							next
						end
						
# ** FIXME - drawn:::	if (r.drawn) then tags[':drawn']='yes' end

						if (a[c.subpart])
							a[c.subpart]=Marshal.load( Marshal.dump(a[c.subpart]))
							a[c.subpart].merge_with(r)
						else
							a[c.subpart]=r
						end
					end
				end
			end
		end
		
		def new_rule_chain
			if @rulechains[@rcpos].rules.length>0
				@rcpos+=1
				@rulechains[@rcpos]=RuleChain.new()
			end
		end
		
		def add_styles(a)
			@styles=@styles.concat(a)
		end
		
		def to_s
			"[StyleChooser: rulechains #{@rulechains} | styles #{@styles}]"
		end
		
		private
		
		def maxwidth(tags,style,key)
			if tags.respond_to?('set_maxwidth') then tags.set_maxwidth(style.get(tags,key,0)) end
		end

	end
end

