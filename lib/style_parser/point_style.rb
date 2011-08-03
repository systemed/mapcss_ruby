module StyleParser
	class PointStyle < Style

		PROPNAMES = ['icon_image','icon_width','icon_height','rotation'];
			
		def drawn
			return !properties['icon_image'].nil?
		end

	end
end
