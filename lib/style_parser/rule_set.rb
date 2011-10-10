module StyleParser

	class RuleSet

		def initialize(mins, maxs)
			@minscale = mins
			@maxscale = maxs
			@imagewidths = {}
		end
		
		def get_styles(entity, tags, zoom)
			sl=StyleList.new
			@choosers.each do |sc| 
				sc.update_styles(entity, tags, sl, @imagewidths, zoom)
			end
			sl
		end
		
		def parse_from_file(filename)
			css=IO.read(filename)
			while css =~ IMPORT
				directive=$&
				import=IO.read($1)
				css.gsub!(directive,import)
			end
			parse(css)
		end
		
		def parse(css)
			previous = 0				# what was the previous CSS item?
			sc = StyleChooser.new()		# currently being assembled
			@choosers = []
			
			while (css.length>0)
				# CSS comment
				if css =~ COMMENT
					css.sub!(COMMENT,'')

				# Whitespace (probably only at beginning of file)
				elsif css =~ WHITESPACE
					css.sub!(WHITESPACE,'')
			
				# Class - .motorway, .builtup, :hover
				elsif css =~ CLASS
					if previous==DECLARATION_OBJECT then save_chooser(sc); sc=StyleChooser.new(); end
					css.sub!(CLASS, '')
					sc.currentchain.add_condition_to_last(Condition.new('set',$1))
					previous = CONDITION_OBJECT
			
				# Not class - !.motorway, !.builtup, !:hover
				elsif css =~ NOT_CLASS
					if previous==DECLARATION_OBJECT then save_chooser(sc); sc=StyleChooser.new(); end
					css.sub!(NOT_CLASS, '')
					sc.currentchain.add_condition_to_last(Condition.new('unset',$1))
					previous = CONDITION_OBJECT
			
				# Zoom
				elsif css =~ ZOOM
					if previous!=ENTITY_OBJECT and previous!=CONDITION_OBJECT then sc.currentchain.add_rule(); end
					css.sub!(ZOOM, '')
					z = parse_zoom($1)
					sc.currentchain.add_zoom_to_last(z[0],z[1])
					sc.zoomspecific=true
					previous = ZOOM_OBJECT
			
				# Grouping
				elsif css =~ GROUP
					css.sub!(GROUP, '')
					sc.new_rule_chain()
					previous = GROUP_OBJECT
			
				# Condition - [highway=primary]
				elsif css =~ CONDITION
					if previous==DECLARATION_OBJECT then save_chooser(sc); sc=StyleChooser.new(); end
					if previous!=ENTITY_OBJECT and previous!= ZOOM_OBJECT and previous!=CONDITION_OBJECT then sc.currentchain.add_rule(); end
					css.sub!(CONDITION, '')
					sc.currentchain.add_condition_to_last(parse_condition($1))
					previous = CONDITION_OBJECT
			
				# Entity - way, node, relation
				elsif css =~ ENTITY
					if previous==DECLARATION_OBJECT then save_chooser(sc); sc=StyleChooser.new(); end
					css.sub!(ENTITY, '')
					sc.currentchain.add_rule($1)
					previous = ENTITY_OBJECT
			
				# Subpart - ::centreline
				elsif css =~ SUBPART
					if previous==DECLARATION_OBJECT then save_chooser(sc); sc=StyleChooser.new(); end
					css.sub!(SUBPART, '')
					sc.currentchain.set_subpart($1)
					previous = SUBPART_OBJECT
				
				# Declaration - { ... }
				elsif css =~ DECLARATION
					css.sub!(DECLARATION, '')
					sc.add_styles(parse_declaration($1))
					previous = DECLARATION_OBJECT
				
				# Unknown pattern
				elsif css =~ UNKNOWN
					css.sub!(UNKNOWN, '')
					puts "Unknown: #{$1}"
				
				# Broken
				else
					puts "Choked on #{css}"
					exit
				end
			end
			if previous==DECLARATION_OBJECT then save_chooser(sc); sc=StyleChooser.new(); end
		end
		
		private
		
		def save_chooser(sc)
			@choosers.push(sc)
		end
		
		def parse_declaration(s)
			styles=[]
			t={}

			# Create styles
			ss=ShapeStyle.new
			ps=PointStyle.new
			ts=TextStyle.new
			hs=ShieldStyle.new
			xs=InstructionStyle.new

			# Set each property
			s.split(';').each do |a|
				if    a=~ASSIGNMENT      then v=$2; k=$1.gsub(DASH,'_'); t[k]=v
				elsif a=~SET_TAG         then xs.add_set_tag($1,$2)
				elsif a=~SET_TAG_TRUE    then xs.add_set_tag($1,true)
				elsif a=~EXIT            then xs.set_property_from_string('breaker',true)
				end
			end

			# Find sublayer
			ss.sublayer=ps.sublayer=ts.sublayer=hs.sublayer=t['z_index'] ? t['z_index'] : 5
			xs.sublayer=10
			t.delete('z_index')
			
			# Munge special values
			if t['font_weight'    ] then t['font_bold'     ] = (t['font_weight'    ]=~BOLD     ) ? true:false; t.delete('font_weight'    ) end
			if t['font_style'     ] then t['font_italic'   ] = (t['font_style'     ]=~ITALIC   ) ? true:false; t.delete('font_style'     ) end
			if t['text_decoration'] then t['font_underline'] = (t['text_decoration']=~UNDERLINE) ? true:false; t.delete('text_decoration') end
			if t['text_position'  ] then t['text_center'   ] = (t['text_position'  ]=~CENTER   ) ? true:false; t.delete('text_position'  ) end
			if t['text_transform' ] then t['font_caps'     ] = (t['text_transform' ]=~CAPS     ) ? true:false; t.delete('text_transform' ) end

			# Assign each property to the appropriate style
			t.each do |k,v|
				if k=~COLOR then v=parse_css_color(v) end
				if    ss.style_defines(k) then ss.set(k,v)
				elsif ps.style_defines(k) then ps.set(k,v)
				elsif ts.style_defines(k) then ts.set(k,v)
				elsif hs.style_defines(k) then hs.set(k,v)
				end
			end

			# Add each style to list
			if (ss.active) then styles.push(ss) end
			if (ps.active) then styles.push(ps) end
			if (ts.active) then styles.push(ts) end
			if (hs.active) then styles.push(hs) end
			if (xs.active) then styles.push(xs) end
			styles
		end
		
		def parse_zoom(s)
			if    s =~ ZOOM_MINMAX then return [$1,$2]
			elsif s =~ ZOOM_MIN    then return [$1,@maxscale]
			elsif s =~ ZOOM_MAX    then return [@minscale,$2]
			elsif s =~ ZOOM_SINGLE then return [$1,$2]
			end
			nil
		end

		def parse_condition(s)
			if    s=~CONDITION_TRUE  then return Condition.new('true' ,$1)
			elsif s=~CONDITION_FALSE then return Condition.new('false',$1)
			elsif s=~CONDITION_SET   then return Condition.new('set'  ,$1)
			elsif s=~CONDITION_UNSET then return Condition.new('unset',$1)
			elsif s=~CONDITION_NE    then return Condition.new('ne'	  ,$1,$2)
			elsif s=~CONDITION_GT    then return Condition.new('>'	  ,$1,$2)
			elsif s=~CONDITION_GE    then return Condition.new('>='	  ,$1,$2)
			elsif s=~CONDITION_LT    then return Condition.new('<'	  ,$1,$2)
			elsif s=~CONDITION_LE    then return Condition.new('<='	  ,$1,$2)
			elsif s=~CONDITION_REGEX then return Condition.new('regex',$1,$2)
			elsif s=~CONDITION_EQ    then return Condition.new('eq'	  ,$1,$2)
			end
			nil
		end

		def parse_css_color(s)
			s.downcase!
			if CSSCOLORS[s] then return CSSCOLORS[s] end
			if s=~HEX
				if    $1.length==6 then return $1.hex
				elsif $1.length==3 then return ("0x"+$1[0].chr+$1[0].chr+$1[1].chr+$1[1].chr+$1[2].chr+$1[2].chr).hex
				end
			end
			0
		end
		
		# Identifiers for each part of a selector

		ZOOM_OBJECT        = 2
		GROUP_OBJECT       = 3
		CONDITION_OBJECT   = 4
		ENTITY_OBJECT      = 5
		DECLARATION_OBJECT = 6
		SUBPART_OBJECT     = 7

		# Regular expressions

		WHITESPACE      =/\A \s+ /mx
		COMMENT	        =/\A \/\* .+? \*\/ \s* /mx
		CLASS	        =/\A ([\.:]\w+) \s* /mx
		NOT_CLASS       =/\A !([\.:]\w+) \s* /mx
		ZOOM	        =/\A \| \s* z([\d\-]+) \s* /imx
		GROUP	        =/\A , \s* /imx
		CONDITION       =/\A \[(.+?)\] \s* /mx
		ENTITY	        =/\A (\w+) \s* /mx
		DECLARATION     =/\A \{(.+?)\} \s* /mx
		SUBPART	        =/\A ::(\w+) \s* /mx
		UNKNOWN	        =/\A (\S+) \s* /mx

		ZOOM_MINMAX     =/\A (\d+)\-(\d+) $/mx
		ZOOM_MIN        =/\A (\d+)\-      $/mx
		ZOOM_MAX        =/\A      \-(\d+) $/mx
		ZOOM_SINGLE     =/\A        (\d+) $/mx

		CONDITION_TRUE  =/\A \s* ([:\w]+) \s* = \s* yes \s*  $/imx
		CONDITION_FALSE =/\A \s* ([:\w]+) \s* = \s* no  \s*  $/imx
		CONDITION_SET   =/\A \s* ([:\w]+) \s* $/mx
		CONDITION_UNSET =/\A \s* !([:\w]+) \s* $/mx
		CONDITION_EQ    =/\A \s* ([:\w]+) \s* =  \s* (.+) \s* $/mx
		CONDITION_NE    =/\A \s* ([:\w]+) \s* != \s* (.+) \s* $/mx
		CONDITION_GT    =/\A \s* ([:\w]+) \s* >  \s* (.+) \s* $/mx
		CONDITION_GE    =/\A \s* ([:\w]+) \s* >= \s* (.+) \s* $/mx
		CONDITION_LT    =/\A \s* ([:\w]+) \s* <  \s* (.+) \s* $/mx
		CONDITION_LE    =/\A \s* ([:\w]+) \s* <= \s* (.+) \s* $/mx
		CONDITION_REGEX =/\A \s* ([:\w]+) \s* =~\/ \s* (.+) \/ \s* $/mx

		ASSIGNMENT_EVAL	=/\A \s* (\S+) \s* \:      \s* eval \s* \( \s* ' (.+?) ' \s* \) \s* $/imx
		ASSIGNMENT		=/\A \s* (\S+) \s* \:      \s*          (.+?) \s*                   $/mx
		SET_TAG_EVAL	=/\A \s* set \s+(\S+)\s* = \s* eval \s* \( \s* ' (.+?) ' \s* \) \s* $/imx
		SET_TAG			=/\A \s* set \s+(\S+)\s* = \s*          (.+?) \s*                   $/imx
		SET_TAG_TRUE	=/\A \s* set \s+(\S+)\s* $/imx
		EXIT			=/\A \s* exit \s* $/imx

		IMPORT			=/@import\s*[^'"]*['"]([^'"]+)['"][^;]*;/im

		DASH=/\-/
		COLOR=/color$/
		BOLD=/\Abold$/i
		ITALIC=/\Aitalic|oblique$/i
		UNDERLINE=/\Aunderline$/i
		CAPS=/\Auppercase$/i
		CENTER=/\Acenter$/i
		FALSE=/\A(no|false|0)$/i

		HEX=/\A#([0-9a-f]+)$/i

		CSSCOLORS = {
			'aliceblue' => 0xf0f8ff,
			'antiquewhite' => 0xfaebd7,
			'aqua' => 0x00ffff,
			'aquamarine' => 0x7fffd4,
			'azure' => 0xf0ffff,
			'beige' => 0xf5f5dc,
			'bisque' => 0xffe4c4,
			'black' => 0x000000,
			'blanchedalmond' => 0xffebcd,
			'blue' => 0x0000ff,
			'blueviolet' => 0x8a2be2,
			'brown' => 0xa52a2a,
			'burlywood' => 0xdeb887,
			'cadetblue' => 0x5f9ea0,
			'chartreuse' => 0x7fff00,
			'chocolate' => 0xd2691e,
			'coral' => 0xff7f50,
			'cornflowerblue' => 0x6495ed,
			'cornsilk' => 0xfff8dc,
			'crimson' => 0xdc143c,
			'cyan' => 0x00ffff,
			'darkblue' => 0x00008b,
			'darkcyan' => 0x008b8b,
			'darkgoldenrod' => 0xb8860b,
			'darkgray' => 0xa9a9a9,
			'darkgreen' => 0x006400,
			'darkkhaki' => 0xbdb76b,
			'darkmagenta' => 0x8b008b,
			'darkolivegreen' => 0x556b2f,
			'darkorange' => 0xff8c00,
			'darkorchid' => 0x9932cc,
			'darkred' => 0x8b0000,
			'darksalmon' => 0xe9967a,
			'darkseagreen' => 0x8fbc8f,
			'darkslateblue' => 0x483d8b,
			'darkslategray' => 0x2f4f4f,
			'darkturquoise' => 0x00ced1,
			'darkviolet' => 0x9400d3,
			'deeppink' => 0xff1493,
			'deepskyblue' => 0x00bfff,
			'dimgray' => 0x696969,
			'dodgerblue' => 0x1e90ff,
			'firebrick' => 0xb22222,
			'floralwhite' => 0xfffaf0,
			'forestgreen' => 0x228b22,
			'fuchsia' => 0xff00ff,
			'gainsboro' => 0xdcdcdc,
			'ghostwhite' => 0xf8f8ff,
			'gold' => 0xffd700,
			'goldenrod' => 0xdaa520,
			'gray' => 0x808080,
			'green' => 0x008000,
			'greenyellow' => 0xadff2f,
			'honeydew' => 0xf0fff0,
			'hotpink' => 0xff69b4,
			'indianred ' => 0xcd5c5c,
			'indigo ' => 0x4b0082,
			'ivory' => 0xfffff0,
			'khaki' => 0xf0e68c,
			'lavender' => 0xe6e6fa,
			'lavenderblush' => 0xfff0f5,
			'lawngreen' => 0x7cfc00,
			'lemonchiffon' => 0xfffacd,
			'lightblue' => 0xadd8e6,
			'lightcoral' => 0xf08080,
			'lightcyan' => 0xe0ffff,
			'lightgoldenrodyellow' => 0xfafad2,
			'lightgrey' => 0xd3d3d3,
			'lightgreen' => 0x90ee90,
			'lightpink' => 0xffb6c1,
			'lightsalmon' => 0xffa07a,
			'lightseagreen' => 0x20b2aa,
			'lightskyblue' => 0x87cefa,
			'lightslategray' => 0x778899,
			'lightsteelblue' => 0xb0c4de,
			'lightyellow' => 0xffffe0,
			'lime' => 0x00ff00,
			'limegreen' => 0x32cd32,
			'linen' => 0xfaf0e6,
			'magenta' => 0xff00ff,
			'maroon' => 0x800000,
			'mediumaquamarine' => 0x66cdaa,
			'mediumblue' => 0x0000cd,
			'mediumorchid' => 0xba55d3,
			'mediumpurple' => 0x9370d8,
			'mediumseagreen' => 0x3cb371,
			'mediumslateblue' => 0x7b68ee,
			'mediumspringgreen' => 0x00fa9a,
			'mediumturquoise' => 0x48d1cc,
			'mediumvioletred' => 0xc71585,
			'midnightblue' => 0x191970,
			'mintcream' => 0xf5fffa,
			'mistyrose' => 0xffe4e1,
			'moccasin' => 0xffe4b5,
			'navajowhite' => 0xffdead,
			'navy' => 0x000080,
			'oldlace' => 0xfdf5e6,
			'olive' => 0x808000,
			'olivedrab' => 0x6b8e23,
			'orange' => 0xffa500,
			'orangered' => 0xff4500,
			'orchid' => 0xda70d6,
			'palegoldenrod' => 0xeee8aa,
			'palegreen' => 0x98fb98,
			'paleturquoise' => 0xafeeee,
			'palevioletred' => 0xd87093,
			'papayawhip' => 0xffefd5,
			'peachpuff' => 0xffdab9,
			'peru' => 0xcd853f,
			'pink' => 0xffc0cb,
			'plum' => 0xdda0dd,
			'powderblue' => 0xb0e0e6,
			'purple' => 0x800080,
			'red' => 0xff0000,
			'rosybrown' => 0xbc8f8f,
			'royalblue' => 0x4169e1,
			'saddlebrown' => 0x8b4513,
			'salmon' => 0xfa8072,
			'sandybrown' => 0xf4a460,
			'seagreen' => 0x2e8b57,
			'seashell' => 0xfff5ee,
			'sienna' => 0xa0522d,
			'silver' => 0xc0c0c0,
			'skyblue' => 0x87ceeb,
			'slateblue' => 0x6a5acd,
			'slategray' => 0x708090,
			'snow' => 0xfffafa,
			'springgreen' => 0x00ff7f,
			'steelblue' => 0x4682b4,
			'tan' => 0xd2b48c,
			'teal' => 0x008080,
			'thistle' => 0xd8bfd8,
			'tomato' => 0xff6347,
			'turquoise' => 0x40e0d0,
			'violet' => 0xee82ee,
			'wheat' => 0xf5deb3,
			'white' => 0xffffff,
			'whitesmoke' => 0xf5f5f5,
			'yellow' => 0xffff00,
			'yellowgreen' => 0x9acd32 }

	end
end
