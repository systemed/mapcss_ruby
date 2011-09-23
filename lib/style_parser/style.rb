module StyleParser
	class Style

		attr_accessor :merged, :edited, :interactive, :declarations
		attr_reader   :sublayer
		
		PROPNAMES=[]
		EVAL=/\Aeval \s* \( \s* ['"] (.+?) ['"] \s* \) \s* $/imx
		
		def initialize
			@declarations={}
			@merged=false
			@edited=false
			@sublayer=5
			@interactive=true
		end
		
		def propnames
			self.class::PROPNAMES
		end
		
		def sublayer=(s)
			@sublayer=s.to_i
		end
		
		def drawn
			return false
		end

		# Return a declaration value, parsing eval if needs be
		def get(tags, k, default=nil)
			v=@declarations[k]||=default
			if tags.respond_to?('eval') and v=~EVAL then v=tags.eval($1) end
			v
		end
		
		def get_raw(k)
			@declarations[k]
		end
		
		# Set a declaration value
		def set(k, v)
			@declarations[k]=v
		end
		
		# Is there a declaration value for this key?
		def defined(k)
			@declarations.has_key?(k)
		end
		
		# Does this style use this declaration key?
		def style_defines(k)
			propnames.include?(k)
		end

		# Are any of the keys relevant to this style?
		def active
			propnames.each do |k|
				if defined(k) then return true end
			end
			false
		end

		# Merge with another style
		def merge_with(additional)
			propnames.each do |k|
				if additional.defined(k) then set(k,additional.get_raw(k)) end
			end
			@merged=true
		end
		
		# Write out tags
		def to_s
			t="#{self.class}: "
			@declarations.each { |k,v| t+="#{k}='#{v}' " }
			t
		end

	end
end

