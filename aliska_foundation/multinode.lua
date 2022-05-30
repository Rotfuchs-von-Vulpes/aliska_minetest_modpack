multinode = {}

function multinode.create_multinode(node, w, h, l)
	return function(pos)
		local p1, p2 = pos, pos

		for i=0, w do
			local p1_add = vector.add(p1, {x=-1, y=0, z=0})
			local p2_add = vector.add(p2, {x=1, y=0, z=0})
			if minetest.get_node(p1_add).name == node then
				p1 = p1_add
			end
			if minetest.get_node(p2_add).name == node then
				p2 = p2_add
			end
		end
		for i=0, h do
			local p1_add = vector.add(p1, {x=0, y=-1, z=0})
			local p2_add = vector.add(p2, {x=0, y=1, z=0})
			if minetest.get_node(p1_add).name == node then
				p1 = p1_add
			end
			if minetest.get_node(p2_add).name == node then
				p2 = p2_add
			end
		end
		for i=0, l do
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
	end,
	function (pos, oldnode, oldmeta)
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
	end
end
