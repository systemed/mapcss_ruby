module PDFRenderer
	class TagsBinding

		# Tags object
		# - access it like a hash (i.e. [] and []= methods)
		# - if a value is 'eval(...)', then get the results
		# _width=0 should be set elsewhere

		def initialize(_entity,_states={})
			@entity=_entity
			@tb=get_binding
			@bindingactive=false
			@t={}	# simple hash used for faster access (avoiding eval) where possible
			_entity.tags.each { |k,v| @t[k]=v }
			_states.each      { |k,v| @t[k]=v }
		end

		def [](k)
			@t[k]
		end
		
		def []=(k,v)
			@t[k]=v
			return unless @bindingactive
			set_binding(k,v)
		end
		
		def has_key?(k)
			@t.has_key?(k)
		end
		
		def eval(_exp)
			if !@bindingactive then initialise_binding end
			@tb.eval(_exp)
			# ** this won't cope with anything like 'addr:housenumber+3', because the ':' will break it
		end

		def set_maxwidth(v)
			width=@tb.eval("[_width.to_f,#{v}.to_f].max")
			@t['_width']=width
			if @bindingactive then @tb.eval("_width=#{width}") end
		end

		def to_s
			t="TagsBinding: #{@t} // "
			@tb.eval("local_variables").each do |k|
				t+=" #{k}="+@tb.eval("#{k}").to_s
			end
			t
		end

		private
		
		def initialise_binding
			@t.each { |k,v| set_binding(k,v) }
			@bindingactive=true
		end

		def set_binding(k,v)
			k=substitute(k)
			if v.respond_to?('dump') then @tb.eval("#{k}=#{v.dump}")
			                         else @tb.eval("#{k}=#{v}") end
		end

		def substitute(k)
			k.gsub(/\W/, '__')
		end
		
		def get_binding
			_width=0
			binding
		end
		
	end
end
