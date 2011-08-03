Ruby MapCSS parser
==================

This is an experimental Ruby parser for MapCSS 0.2, based on the Halcyon parser.

== Dependencies ==

You'll require Jochen Topf's OSMlib library. We use the Node, Way and Relation objects from this. Unlike Halcyon, OSMlib doesn't keep track of 'parent' objects, so we have a singleton Dictionary class to store this mapping.

== How to use ==

Install style_parser and style_parser.rb into a lib/ directory. Require style_parser as usual.

Read a MapCSS file like this:

	css=IO.read('opencyclemap.css')
	ruleset=StyleParser::RuleSet.new(12,20)					# 12 and 20 are min/max zoom levels
	ruleset.parse(css)
	
Create the parent object mappings from an OSMlib database:

	dictionary = StyleParser::Dictionary.instance
	dictionary.populate(db)

Then get the style for any OSM object like this:

	entity=db.get_way(3044458)
	stylelist=ruleset.get_styles(entity,entity.tags,14)		# 14 is the target zoom level
	puts stylelist

You can see an example of this in osm_test.rb.

== Limitations ==

- It hasn't really been tested at all.
- The test stylesheet is MapCSS 0.1. That's not too helpful. ;)
- No evals yet, though these should be pretty trivial to implement in Ruby (not like AS3...).
- Any limitations of Halcyon's parser are also present here.
- We don't yet handle @import directives for nested CSS files. You'll need to parse these yourself.

== Licence and author ==

WTFPL. You can do whatever the fuck you want with this code. Code by Richard Fairhurst, summer 2011.

Example files: OpenCycleMap Potlatch 2 style by Andy Allan, Charlbury OpenStreetMap data by OpenStreetMap contributors (CC-BY-SA).
