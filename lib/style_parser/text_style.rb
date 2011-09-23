module StyleParser
	class TextStyle < Style

		PROPNAMES = ['font_family','font_bold','font_italic','font_caps','font_size',
				'text_color','text_offset','max_width',
				'text','text_halo_color','text_halo_radius','text_center',
				'letter_spacing'];
			
		def drawn
			return defined('text')
		end

	end
end
