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
		{2, 3, 2},
		{1, 2, 1}
	},
	{
		{1, 1, 1},
		{1, 1, 1},
		{1, 1, 1}
	}
}, {
	'aliska_expansion:blast_furnace',
	'aliska_expansion:blast_furnace_inactive',
	'aliska_expansion:blast_furnace_center'
})

local function get_form(pos, fuel_percent, item_percent)
	local context = 'nodemeta:'..pos.x..','..pos.y..','..pos.z

	return 'size[9,8;]'..
	'list['..context..';src;3,0.5;1,1;]'..
	"image[3,1.5;1,1;aliska_fire_low.png^[lowpart:"..
	(fuel_percent)..":aliska_fire_high.png]"..
	"image[4,1.5;1,1;aliska_arrow_low.png^[lowpart:"..
	(item_percent)..":aliska_arrow_high.png^[transformR270]"..
	'list['..context..';fuel;3,2.5;1,1;]'..
	'list['..context..';dst;5,1.5;1,1;]'..
	'list[current_player;main;0,4;9,4;]'..
	'listring['..context..';dst]'..
	'listring[current_player;main]'..
	'listring['..context..';src]'..
	'listring[current_player;main]'..
	'listring['..context..';fuel]'..
	'listring[current_player;main]'..
	default.get_hotbar_bg(0, 4)
end

local function can_dig(pos, player)
	local player_inv = player:get_inventory()
	local node_inv = minetest.get_meta(
		minetest.deserialize(minetest.get_meta(pos):get_string('main_pos'))
	):get_inventory()

	local src = node_inv:get_list('src')[1]
	if player_inv:room_for_item('main', src) then
		player_inv:add_item('main', src)
	else 
		return false
	end

	local fuel = node_inv:get_list('fuel')[1]
	if player_inv:room_for_item('main', fuel) then
		player_inv:add_item('main', fuel)
	else 
		return false
	end

	local dst = node_inv:get_list('dst')[1]
	if player_inv:room_for_item('main', dst) then
		player_inv:add_item('main', dst)
	else 
		return false
	end

	return true
end

blast_furnace = aliska.create_combustion_machine(
	'Blast furnace',
	'aliska_expansion:blast_furnace_active',
	'aliska_expansion:blast_furnace_inactive',
	160,
	function(pos, node)
		local positions = {}
	
		table.insert(positions, vector.add(pos, {x=-1, y=0, z=0}))
		table.insert(positions, vector.add(pos, {x=1, y=0, z=0}))
		table.insert(positions, vector.add(pos, {x=0, y=0, z=-1}))
		table.insert(positions, vector.add(pos, {x=0, y=0, z=1}))
	
		if minetest.get_node(positions[1]).name == node then
			return
		end
	
		for _, pos in ipairs(positions) do
			minetest.swap_node(pos, {name=node})
		end
	end,
	function(stack)
		local item = stack:get_name()

		return item == 'aliska_foudation:charcoal' or item == 'aliska_foudation:coke'
	end,
	function(main_pos, fuel_percent, item_percent, text)
		local meta = minetest.get_meta(main_pos)
		local p1 = minetest.deserialize(meta:get_string('p1'))
		local p2 = minetest.deserialize(meta:get_string('p2'))
	
		for i=p1.x, p2.x do
			for j=p1.y, p2.y do
				for k=p1.z, p2.z do
					local pos = {x=i, y=j, z=k}
					local meta = minetest.get_meta(pos)
	
					meta:set_string('formspec',
						get_form(main_pos, fuel_percent, item_percent))
					meta:set_string('infotext', text)
				end
			end
		end
	end
)

blast_furnace:register_craft(
	'aliska_foudation:raw_aluminium', 'aliska_foudation:aluminium_ingot'
)
blast_furnace:register_craft('aliska_foudation:iron_ingot', 'default:steel_ingot')
blast_furnace:register_craft('aliska_foudation:iron_block', 'default:steelblock')

local on_construct, after_dig_node, on_blast = aliska.create_multinode(
	'aliska_expansion:blast_furnace_bricks', 3, 4, 3, matrix_replace,
	function(pos, main_pos)
		local meta = minetest.get_meta(pos)

		meta:set_string('formspec', get_form(main_pos, 0, 0))
	end,
	function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		inv:set_size('src', 1)
		inv:set_size('dst', 1)
		inv:set_size('fuel', 1)
	end
)

minetest.register_node('aliska_expansion:blast_furnace_active', {
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
	drop = 'aliska_expansion:blast_furnace_bricks',
	after_dig_node = after_dig_node,
	on_blast = function(pos) end,
	can_dig = can_dig,
})
minetest.register_node('aliska_expansion:blast_furnace_inactive', {
	description = 'Blast Furnace',
	tiles = { 'aliska_blast_furnace_inactive.png' },
	groups = {cracky = 3, not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
	drop = 'aliska_expansion:blast_furnace_bricks',
	on_rightclick = on_rightclick,
	after_dig_node = after_dig_node,
	on_blast = function(pos) end,
	can_dig = can_dig,
})
minetest.register_node('aliska_expansion:blast_furnace', {
	description = 'Blast Furnace',
	tiles = aliska.make_brick_tiles('aliska_blast_furnace_bricks'),
	groups = {cracky = 3, not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
	drop = 'aliska_expansion:blast_furnace_bricks',
	after_dig_node = after_dig_node,
	on_blast = function(pos) end,
	can_dig = can_dig,
})
minetest.register_node('aliska_expansion:blast_furnace_center', {
	description = 'Blast Furnace',
	tiles = aliska.make_brick_tiles('aliska_blast_furnace_bricks'),
	groups = {cracky = 3, not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
	drop = 'aliska_expansion:blast_furnace_bricks',

	after_dig_node = after_dig_node,

	can_dig = blast_furnace.can_dig,

	on_timer = blast_furnace:get_node_timer(),

	on_metadata_inventory_move = blast_furnace.inventory_interaction,
	on_metadata_inventory_put = blast_furnace.inventory_interaction,
	on_metadata_inventory_take = blast_furnace.inventory_interaction,
	on_blast = on_blast,
	
	allow_metadata_inventory_put = blast_furnace.allow_metadata_inventory_put,
	allow_metadata_inventory_move = blast_furnace.allow_metadata_inventory_move,
})

minetest.register_node('aliska_expansion:blast_furnace_bricks', {
	description = 'Blast Furnace Bricks',
	tiles = aliska.make_brick_tiles('aliska_blast_furnace_bricks'),
	groups = {cracky = 3},
	sounds = default.node_sound_stone_defaults(),
	drop = 'aliska_expansion:blast_furnace_bricks',
	on_construct = on_construct
})

aliska.register_craft(
	'aliska_expansion:blast_furnace_bricks 3',
	{1, 2, 1, 2, 1, 2, 1, 2, 1},
	{'group:sand', 'aliska_expansion:coke_furnace_bricks'}
)
