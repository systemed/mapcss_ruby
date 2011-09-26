require 'singleton'

module StyleParser
	class Dictionary

		include Singleton
		
		def populate(database)
			@dictionary={}

			database.relations.values.each do |relation|
				relation_loaded_members(database,relation).each do |member|
					add(relation,member)
				end
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
		
		def has_parent_ways(child)
			parent_objects(child) do |parent|
				if parent.type=='way' then return true end
			end
			false
		end
		
		def num_parent_ways(child)
			i=0
			parent_objects(child).count do |parent|
				parent.type=='way'
			end
		end
		
		def parent_relations_of_type(child,type,role=nil)
			parent_objects(child).collect do |parent|
				if parent.type=='relation' && 
				   parent.tags['type'] && parent.tags['type']==type &&
				   (!role || parent.member(child.type,child.id).role==role) then parent end
			end.compact
		end
		
		def is_member_of(child,type,role=nil)
			parent_objects(child).each do |parent|
				if parent.type=='relation' &&
				   parent.tags['type'] && parent.tags['type']==type &&
				   (!role || parent.member(child.type,child.id).role==role) then return true end
			end
			false
		end
		
		def relation_loaded_members(database,relation,role=nil)
			relation.members.collect do |member|
                obj = case member.type
                    when 'node'     then database.get_node(member.ref)
                    when 'way'      then database.get_way(member.ref)
                    when 'relation' then database.get_relation(member.ref)
                end
                if !role || member.role==role then obj end
            end.compact
		end

		private

		def add(parent,child)
			if @dictionary[child] and !@dictionary[child].index(parent)
				@dictionary[child].push(parent)
			elsif !@dictionary[child]
				@dictionary[child]=[parent]
			end
		end
		
	end
end
