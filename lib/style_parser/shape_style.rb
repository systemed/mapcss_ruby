module StyleParser
	class ShapeStyle < Style

		PROPNAMES = ['width','color','opacity','dashes','linecap','linejoin','line_style',
			'fill_color','fill_opacity','fill_image',
			'casing_width','casing_color','casing_opacity','casing_dashes','layer' ];
			
		def drawn
			return (defined('fill_image') or
					defined('fill_color') or
					defined('width') or
					defined('casing_width'))
		end

	end
end
