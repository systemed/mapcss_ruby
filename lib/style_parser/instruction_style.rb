module StyleParser
	class InstructionStyle < Style

		attr_accessor	:set_tags, :breaker

		def add_set_tag(k,v)
			@edited=true;
			if (!@set_tags) then set_tags={} end
			set_tags[k]=v
		end

	end
end
