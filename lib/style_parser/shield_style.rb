module StyleParser
	class ShieldStyle < Style

		PROPNAMES = ['shield_image','shield_width','shield_height'];
			
		def drawn
			return !properties['shield_image'].nil?
		end

	end
end
