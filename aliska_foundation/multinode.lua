function aliska.create_node_matrix(table, ingredients)
	local matrix = {}

	for i, _ in ipairs(table[1]) do
		matrix[i] = {}
		for j, _ in ipairs(table) do
			matrix[i][j] = {}
			for k, _ in ipairs(table[1][1]) do
				matrix[i][j][k] = ingredients[table[#table-j+1][i][k]]
			end
		end
	end

	return matrix
end

function aliska.create_multinode(
		node, w, h, l, matrix,
		on_place_node, after_place_nodes
	)
	return function(pos)
		function find_neighbors(pos)
			local p1, p2 = pos, pos
	
			for i=1, w do
				local p1_add = vector.add(p1, {x=-1, y=0, z=0})
				local p2_add = vector.add(p2, {x=1, y=0, z=0})
				if minetest.get_node(p1_add).name == node then
					p1 = p1_add
				end
				if minetest.get_node(p2_add).name == node then
					p2 = p2_add
				end
			end
			for i=1, h do
				local p1_add = vector.add(p1, {x=0, y=-1, z=0})
				local p2_add = vector.add(p2, {x=0, y=1, z=0})
				if minetest.get_node(p1_add).name == node then
					p1 = p1_add
				end
				if minetest.get_node(p2_add).name == node then
					p2 = p2_add
				end
			end
			for i=1, l do
				local p1_add = vector.add(p1, {x=0, y=0, z=-1})
				local p2_add = vector.add(p2, {x=0, y=0, z=1})
				if minetest.get_node(p1_add).name == node then
					p1 = p1_add
				end
				if minetest.get_node(p2_add).name == node then
					p2 = p2_add
				end
			end
	
			if p2.x - p1.x == w-1 and p2.y - p1.y == h-1 and p2.z - p1.z == l-1 then
				for i=p1.x, p2.x do
					for j=p1.y, p2.y do
						for k=p1.z, p2.z do
							if minetest.get_node({x=i, y=j, z=k}).name ~= node then
								return false
							end
						end
					end
				end
	
				return true, p1, p2
			else
				return false
			end
		end

		local filled, p1, p2 = find_neighbors(pos)

		if filled then
			local main_pos = vector.add(p1, {x=1, y=1, z=1})
			local meta = minetest.get_meta(main_pos)
			local serialized = minetest.serialize(main_pos)

			meta:set_string('p1', minetest.serialize(p1))
			meta:set_string('p2', minetest.serialize(p2))

			for i=p1.x, p2.x do
				for j=p1.y, p2.y do
					for k=p1.z, p2.z do
						local pos = {x=i, y=j, z=k}
						local node = {name=matrix[i-p1.x+1][j-p1.y+1][k-p1.z+1]}

						if node.name then
							minetest.swap_node(
								pos,
								node
							)
						end

						local meta = minetest.get_meta(pos)
						meta:set_string('main_pos', serialized)
						on_place_node(pos, main_pos)
					end
				end
			end

			after_place_nodes(main_pos)
		end
	end,
	function(pos, oldnode, oldmeta)
		local pos_in = minetest.deserialize(oldmeta.fields['main_pos'])
		local meta = minetest.get_meta(pos_in)
	
		local p1 = minetest.deserialize(meta:get_string('p1'))
		local p2 = minetest.deserialize(meta:get_string('p2'))
		
		if not (p1 and p2) then
			return
		end
		
		for i=p1.x, p2.x do
			for j=p1.y, p2.y do
				for k=p1.z, p2.z do
					local current_pos = {x=i, y=j, z=k}
					if not vector.equals(current_pos, pos) then
						minetest.set_node(current_pos, {name=node})
					end
				end
			end
		end
	end,
	function(pos)
		local drops = {}
		local meta = minetest.get_meta(pos)
	
		local p1 = minetest.deserialize(meta:get_string('p1'))
		local p2 = minetest.deserialize(meta:get_string('p2'))

		default.get_inventory_drops(pos, "src", drops)
		default.get_inventory_drops(pos, "fuel", drops)
		default.get_inventory_drops(pos, "dst", drops)
		
		if not (p1 and p2) then
			return
		end
		
		local count = 0
		for i=p1.x, p2.x do
			for j=p1.y, p2.y do
				for k=p1.z, p2.z do
					minetest.set_node({x=i, y=j, z=k}, {name='air'})
					count = count + 1
				end
			end
		end
		drops[#drops+1] = node.." "..count

		return drops
	end
end
