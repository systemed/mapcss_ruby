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
							if r.properties['width'] then sl.maxwidth=[sl.maxwidth,r.properties['width'].to_f].max end
						elsif (r.instance_of? ShieldStyle)
							a=sl.shieldstyles
						elsif (r.instance_of? TextStyle)
							a=sl.textstyles
						elsif (r.instance_of? PointStyle)
							a=sl.pointstyles
							w=0
							if r.properties['icon_width']
								w=r.properties['icon_width']
							elsif (r.properties['icon_image'] and imagewidths[r.properties['icon_image']])
								w.imagewidths[r.properties['icon_image']]
							end
							if (w>sl.maxwidth) then sl.maxwidth=w end
						elsif (r.instance_of? InstructionStyle)
							if r.breaker then return end
							if r.settags then r.settags.each { |k,v| tags[k]=v } end
							next
						end
						
						if (r.drawn) then tags[':drawn']='yes' end
						tags['_width']=sl.maxwidth
						
						if (a[c.subpart])
							if (!a[c.subpart].merged) then a[c.subpart]=a[c.subpart].clone end
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

	end
end

