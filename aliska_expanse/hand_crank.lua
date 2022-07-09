minetest.register_node('aliska_expanse:hand_crank', {
	description = 'Hand Crank',
	tiles = {'aliska_hand_crank.png'},
	inventory_image = 'aliska_hand_crank.png',
	groups = { cracky = 1 },
	drop = 'aliska_expanse:hand_crank',
	paramtype2 = "degrotate",
	drawtype = 'plantlike',
	walkable = false,
	sunlight_propagates = true,

	on_rightclick = function(pos, node)
		local meta = minetest.get_meta(pos)
		local is_rotable = meta:get_int('is_rotable')

		if is_rotable == 1 then
			local temp = node.param2
	
			node.param2 = node.param2 + 10
			minetest.swap_node(pos, node)
	
			local node2 = minetest.get_node(pos)
	
			if node2.param2 < temp then
				minetest.get_node_timer(vector.add(pos, {x=0, y=-1, z=0})):start(0)
			end
		end
	end,

	on_construct = function(pos)
		under_pos = vector.add(pos, {x=0, y=-1, z=0})
		local is_rotable = minetest
			.registered_nodes[minetest.get_node(under_pos).name]
			.groups.aliska_receptor_kinetics
		if is_rotable then
			local meta = minetest.get_meta(pos)
			meta:set_int('is_rotable', 1)
		end
	end
})