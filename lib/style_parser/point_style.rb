module StyleParser
	class PointStyle < Style

		PROPNAMES = ['icon_image','icon_width','icon_height','rotation'];
			
		def drawn
			return defined('icon_image')
		end

	end
end
