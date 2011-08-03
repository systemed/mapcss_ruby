require 'singleton'

module StyleParser
	class Dictionary

		include Singleton
		
		def populate(database)
			@dictionary={}

			database.relations.values.each do |relation|
				ignore_not_found {
					relation.member_objects.each { |member| add(relation,member) }
				}
			end
			
			database.ways.values.each do |way|
				way.node_objects.each { |node| add(way,node) }
			end
		end
		
		def parent_objects(child)
			@dictionary[child] ? @dictionary[child] : []
		end
		
		def parent_relations(child)
			parent_objects(child).collect do |parent|
				if parent.type=='relation' then parent end
			end
		end
		
		def parent_ways(child)
			parent_objects(child).collect do |parent|
				if parent.type=='way' then parent end
			end
		end

		private
		
		def add(parent,child)
			if @dictionary[child] and !@dictionary[child].index(parent)
				@dictionary[child].push(parent)
			elsif !@dictionary[child]
				@dictionary[child]=[parent]
			end
		end
		
		def ignore_not_found
			begin
				yield
			rescue OSM::NotFoundError
			end
		end

	end
end
