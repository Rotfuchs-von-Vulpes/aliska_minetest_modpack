local find_neighbors, on_destruct =
	multinode.create_multinode(MOD_NAME..':coke_furnace_bricks', 3, 3, 3)

local function on_rightclick(pos)
	local meta_out = minetest.get_meta(pos)
	local pos_in = meta_out:get_string('main_pos')
	local meta = minetest.get_meta(minetest.deserialize(pos_in))

	minetest.debug(aliska.serialize(pos_in))
end

minetest.register_node(MOD_NAME..':coke_furnace_active', {
	description = 'Coke Oven',
	tiles = { {
		image = 'aliska_coke_furnace_active.png',
		backface_culling = false,
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 1.5
		},
	} },
	light_source = 14,
	groups = {cracky=2, not_in_creative_inventory=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
	drop = MOD_NAME..':coke_furnace_bricks',
	on_rightclick = on_rightclick,
	after_dig_node = on_destruct,
})
minetest.register_node(MOD_NAME..':coke_furnace_inactive', {
	description = 'Coke Oven',
	tiles = { 'aliska_coke_furnace_inactive.png' },
	groups = {cracky = 3, not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
	drop = MOD_NAME..':coke_furnace_bricks',
	on_rightclick = on_rightclick,
	after_dig_node = on_destruct,
})
minetest.register_node(MOD_NAME..':coke_furnace', {
	description = 'Coke Oven',
	tiles = { 'aliska_coke_furnace_bricks.png' },
	groups = {cracky = 3, not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
	drop = MOD_NAME..':coke_furnace_bricks',
	on_rightclick = on_rightclick,
	after_dig_node = on_destruct,
})

minetest.register_node(MOD_NAME..':coke_furnace_bricks', {
	description = 'Coke Furnace Bricks',
	tiles = { 'aliska_coke_furnace_bricks.png' },
	groups = {cracky = 3},
	sounds = default.node_sound_stone_defaults(),
	drop = MOD_NAME..':coke_furnace_bricks',
	on_construct = function(pos)
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

						if (i == p1.x or i == p2.x) and
							(k == p1.z or k == p2.z) or
							(j == p1.y or j == p2.y)
						then
							minetest.swap_node(
								pos,
								{name=MOD_NAME..':coke_furnace'}
							)
						else
							minetest.swap_node(
								pos,
								{name=MOD_NAME..':coke_furnace_active'}
							)
						end

						local meta = minetest.get_meta(pos)
						meta:set_string('main_pos', serialized)
					end
				end
			end
		end
	end
})
