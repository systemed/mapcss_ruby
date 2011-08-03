module StyleParser
	class ShapeStyle < Style

		PROPNAMES = ['width','color','opacity','dashes','linecap','linejoin','line_style',
			'fill_color','fill_opacity','fill_image',
			'casing_width','casing_color','casing_opacity','casing_dashes','layer' ];
			
		def drawn
			return (properties['fill_image'] or
					properties['fill_color'] or
					properties['width'] or
					properties['casing_width'])
		end

	end
end
