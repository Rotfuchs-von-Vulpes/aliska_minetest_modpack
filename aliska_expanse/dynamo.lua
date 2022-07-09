minetest.register_node('aliska_expanse:dynamo', {
	description = 'Dynamo',
	tiles = {'aliska_grinder_side.png'},
	groups = { cracky = 1, aliska_receptor_kinetics = 1 },
	on_timer = function()
		minetest.debug('AHA! Foi!')
	end,
	on_construct = function(pos)
		local above_pos = vector.add(pos, {x=0, y=1, z=0})
		local node = minetest.get_node(above_pos)

		if node.name == 'aliska_expanse:hand_crank' then
			local meta = minetest.get_meta(above_pos)

			meta:set_int('is_rotable', 1)
		end
	end,
	on_destruct = function(pos)
		local above_pos = vector.add(pos, {x=0, y=1, z=0})
		local node = minetest.get_node(above_pos)

		if node.name == 'aliska_expanse:hand_crank' then
			local meta = minetest.get_meta(above_pos)

			meta:set_int('is_rotable', 0)
		end
	end
})
