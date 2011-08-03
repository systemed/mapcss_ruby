module StyleParser
	class Style

		attr_accessor :merged, :edited, :sublayer, :interactive
		attr_reader   :properties
		
		PROPNAMES=[]
		
		def initialize
			@merged=false
			@edited=false
			@sublayer=5
			@interactive=true
			@properties={}
		end
		
		def propnames
			self.class::PROPNAMES
		end
		
		def merge_with(additional)
			propnames.each do |k|
				if additional.properties[k] then @properties[k]=additional.properties[k] end
			end
			@merged=true
		end
		
		def drawn
			return false
		end
		
		def has_property(k)
			return propnames.include?(k)
		end
		
		def set_property_from_string(k,v)
			# ** TODO: we don't do any sort of casting here. Instead, we rely on 
			#    whatever is getting stuff out of .properties to cast it
			#    (e.g. shapestyle.properties['width'].to_f). This isn't ideal.
			unless propnames.include?(k) then return end
			@properties[k]=v
			@edited=true
		end

	end
end

