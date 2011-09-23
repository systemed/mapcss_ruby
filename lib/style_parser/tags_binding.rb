module PDFRenderer
	class TagsBinding

		# Tags object
		# - access it like a hash (i.e. [] and []= methods)
		# - if a value is 'eval(...)', then get the results
		# _width=0 should be set elsewhere

		def initialize(_entity)
			@entity=_entity
			@tb=get_binding
			_entity.tags.each { |k,v| self[k]=v }
		end

		def [](k)
			k=substitute(k)
			if !has_key?(k) then return nil end
			@tb.eval("#{k}")
		end
		
		def []=(k,v)
			k=substitute(k)
			@tb.eval("#{k}=#{v.dump}")
		end
		
		def has_key?(k)
			k=substitute(k)
			!@tb.eval("defined? #{k}").nil?
		end
		
		def eval(_exp)
			@tb.eval(_exp)
			# ** this won't cope with anything like 'addr:housenumber+3', because the ':' will break it
		end

		def set_maxwidth(v)
			@tb.eval("_width=[_width.to_f,#{v}.to_f].max")
		end

		def to_s
			t='TagsBinding:'
			@tb.eval("local_variables").each do |k|
				t+=" #{k}="+@tb.eval("#{k}").to_s
			end
			t
		end

		private
		
		def substitute(k)
			k.gsub(/\W/, '__')
		end
		
		def get_binding
			_width=0
			binding
		end
		
	end
end
