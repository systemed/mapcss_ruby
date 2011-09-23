module StyleParser
	class ShieldStyle < Style

		PROPNAMES = ['shield_image','shield_width','shield_height'];
			
		def drawn
			return defined('shield_image')
		end

	end
end
