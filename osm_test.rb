$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '.', 'lib'))

	require "OSM"
	require "OSM/StreamParser"
	require "OSM/Database"

	require "style_parser"

	css=IO.read('opencyclemap.css')
	ruleset=StyleParser::RuleSet.new(12,20)
	ruleset.parse(css)

	db = OSM::Database.new

	puts "Reading"
	parser = OSM::StreamParser.new(:filename => 'charlbury.osm', :db => db)

	puts "Parsing"
	parser.parse
	# typing 'export OSMLIB_XML_PARSER=Expat' beforehand would speed things up, if it weren't fucked.

	puts "Creating dictionary"
	dictionary = StyleParser::Dictionary.instance
	dictionary.populate(db)

	puts "Results"
	puts "Nodes: #{db.nodes.values.collect{ |o| o.id }.join(',')}"
	puts "Ways: #{db.ways.values.collect{ |o| o.id }.join(',')}"
	puts "Relations: #{db.relations.values.collect{ |o| o.id }.join(',')}"

	puts "Parents"
	entity=db.get_node(409697)
	puts "#{entity}: #{dictionary.parent_objects(entity)}"
	
	puts "Styles"
	entity=db.get_way(3044458)
	sl=ruleset.get_styles(entity,entity.tags,14)
	puts sl
