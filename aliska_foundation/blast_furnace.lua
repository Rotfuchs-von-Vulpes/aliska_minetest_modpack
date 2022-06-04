local matrix_replace = aliska.create_node_matrix({
	{
		{1, 1, 1},
		{1, 1, 1},
		{1, 1, 1}
	},
	{
		{1, 1, 1},
		{1, 1, 1},
		{1, 1, 1}
	},
	{
		{1, 2, 1},
		{2, 1, 2},
		{1, 2, 1}
	},
	{
		{1, 1, 1},
		{1, 1, 1},
		{1, 1, 1}
	}
}, {MOD_NAME..':blast_furnace', MOD_NAME..':blast_furnace_inactive'})

local on_construct, after_dig_node, on_rightclick = aliska.create_multinode(
	MOD_NAME..':blast_furnace_bricks', 3, 4, 3, matrix_replace,
	function(pos, node, player)
		on_rightclick_in(pos)
	end
)

minetest.register_node(MOD_NAME..':blast_furnace_active', {
	description = 'Blast Furnace',
	tiles = { {
		image = 'aliska_blast_furnace_active.png',
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
	drop = MOD_NAME..':blast_furnace_bricks',
	on_rightclick = on_rightclick,
	after_dig_node = on_destruct,
})
minetest.register_node(MOD_NAME..':blast_furnace_inactive', {
	description = 'Blast Furnace',
	tiles = { 'aliska_blast_furnace_inactive.png' },
	groups = {cracky = 3, not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
	drop = MOD_NAME..':blast_furnace_bricks',
	on_rightclick = on_rightclick,
	after_dig_node = after_dig_node,
})
minetest.register_node(MOD_NAME..':blast_furnace', {
	description = 'Blast Furnace',
	tiles = aliska.make_brick_tiles('aliska_blast_furnace_bricks'),
	groups = {cracky = 3, not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
	drop = MOD_NAME..':blast_furnace_bricks',
	on_rightclick = on_rightclick,
	after_dig_node = after_dig_node,
})

minetest.register_node(MOD_NAME..':blast_furnace_bricks', {
	description = 'Blast Furnace Bricks',
	tiles = aliska.make_brick_tiles('aliska_blast_furnace_bricks'),
	groups = {cracky = 3},
	sounds = default.node_sound_stone_defaults(),
	drop = MOD_NAME..':blast_furnace_bricks',
	on_construct = on_construct
})
