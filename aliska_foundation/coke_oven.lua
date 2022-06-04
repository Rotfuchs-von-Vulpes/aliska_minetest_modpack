local matrix_replace = aliska.create_node_matrix({
	{
		{1, 1, 1},
		{1, 1, 1},
		{1, 1, 1},
	},
	{
		{1, 2, 1},
		{2, 3, 2},
		{1, 2, 1},
	},
	{
		{1, 1, 1},
		{1, 1, 1},
		{1, 1, 1},
	},
}, {
	MOD_NAME..':coke_furnace',
	MOD_NAME..':coke_furnace_inactive',
	MOD_NAME..':coke_furnace_center'
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

local function update_info(main_pos, fuel_percent, item_percent, text)
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

local function swap_node(pos, node)
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

local function allow_metadata_inventory_put(pos, listname, index, stack)
	local item = stack:get_name()
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	if listname == "fuel" then
		if minetest.get_craft_result({method="fuel", width=1, items={stack}}).time ~= 0 then

			return stack:get_count()
		else
			return 0
		end
	elseif listname == "src" then
		return stack:get_count()
	elseif listname == "dst" then
		return 0
	end
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack(from_list, from_index)

	return allow_metadata_inventory_put(pos, to_list, to_index, stack)
end

local function coke_oven_node_timer(pos, elapsed)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local srclist = inv:get_list('src')
	local dstlist = inv:get_list('dst')
	local fuellist = inv:get_list('fuel')

	local fuel_percent = meta:get_int('fuel_percent') or 0
	local item_percent = meta:get_int('item_percent') or 0
	local infotext
	local result = false

	local cooking = meta:get_int('cooking') or 0
	local time = meta:get_int('time') or 0
	local fuel_time = meta:get_int('fuel') or 0
	local fuel_total = meta:get_int('fuel_total') or 0
	local time_total = 150

	function stop_cook()
		item_percent = 0
		infotext = 'Coke oven inactive'
		meta:set_int('item_percent', 0)
		meta:set_int('cooking', 0)
		meta:set_int('time', 0)
	end

	function start_cook()
		if srclist[1]:get_name() == 'default:coal_lump' then
			srclist[1]:take_item(1)
			inv:set_list('src', srclist)

			swap_node(pos, MOD_NAME..':coke_furnace_active')
			infotext = 'Coke oven active\nItem: 0%, Fuel: '..fuel_percent
			meta:set_int('cooking', 1)
			meta:set_int('time', 0)
			result = true
		else
			stop_cook()
		end
	end

	function start_fuel()
		local fuel, afterfuel = minetest.get_craft_result({
			method = "fuel", width = 1, items = fuellist
		})
		if fuel.time ~= 0 then
			fuel_time = fuel.time
			fuel_total = fuel_time
			fuel_percent = 100
			meta:set_int('fuel', fuel_time)
			meta:set_int('fuel_total', fuel_time)
			meta:set_int('fuel_percent', 100)
			inv:set_stack('fuel', 1, afterfuel.items[1])
			result = true

			return true
		end

		return false
	end

	function on_cooked()
		item_percent = 0
		meta:set_int('item_percent', 0)

		if inv:room_for_item('dst', MOD_NAME..':coke') then
			inv:add_item('dst', MOD_NAME..':coke')
			return true
		else
			return false
		end
	end

	function update_cook()
		if time > time_total then return end
		time = time + 1
		item_percent = time / time_total * 100
		meta:set_int('time', time)
		meta:set_int('item_percent', item_percent)
		result = true
	end

	function update_fuel()
		if fuel_time <= 0 then return end
		fuel_time = fuel_time - 1
		fuel_percent = fuel_time / fuel_total * 100
		meta:set_int('fuel', fuel_time)
		meta:set_int('fuel_percent', fuel_percent)
		result = true
	end

	if fuel_time > 0 then
		update_fuel()
	else
		if srclist[1]:get_name() == 'default:coal_lump' or cooking == 1 then
			start_fuel()
		else
			swap_node(pos, MOD_NAME..':coke_furnace_inactive')
		end
	end

	if cooking == 1 then
		if time >= time_total then
			if on_cooked() and fuel_time > 0 then
				start_cook()
			end
		elseif fuel_time > 0 then
			update_cook()
		end
	elseif fuel_time > 0 then
		start_cook()
	end

	item_percent = math.floor(item_percent * 100) / 100
	fuel_percent = math.floor(fuel_percent * 100) / 100
	infotext = 'Coke oven active\nItem: '..item_percent..
	'%, fuel: '..fuel_percent..'%'
	update_info(pos, fuel_percent, item_percent, infotext)
	return result
end

local on_construct, after_dig_node, on_blast = aliska.create_multinode(
	MOD_NAME..':coke_furnace_bricks', 3, 3, 3, matrix_replace,
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

		coke_oven_node_timer(pos, 0)
	end
)

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
	after_dig_node = after_dig_node,
	on_blast = function(pos) end,
	can_dig = can_dig,
})
minetest.register_node(MOD_NAME..':coke_furnace_inactive', {
	description = 'Coke Oven',
	tiles = { 'aliska_coke_furnace_inactive.png' },
	groups = {cracky = 3, not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
	drop = MOD_NAME..':coke_furnace_bricks',
	after_dig_node = after_dig_node,
	on_blast = function(pos) end,
	can_dig = can_dig,
})
minetest.register_node(MOD_NAME..':coke_furnace', {
	description = 'Coke Oven',
	tiles = aliska.make_brick_tiles('aliska_coke_furnace_bricks'),
	groups = {cracky = 3, not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
	drop = MOD_NAME..':coke_furnace_bricks',
	after_dig_node = after_dig_node,
	on_blast = function(pos) end,
	can_dig = can_dig,
})
minetest.register_node(MOD_NAME..':coke_furnace_center', {
	description = 'Coke Oven',
	tiles = aliska.make_brick_tiles('aliska_coke_furnace_bricks'),
	groups = {cracky = 3, not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
	drop = MOD_NAME..':coke_furnace_bricks',

	after_dig_node = after_dig_node,

	can_dig = can_dig,

	on_timer = coke_oven_node_timer,

	on_metadata_inventory_move = function(pos)
		minetest.get_node_timer(pos):start(1.0)
	end,
	on_metadata_inventory_put = function(pos)
		-- start timer function, it will sort out whether furnace can burn or not.
		minetest.get_node_timer(pos):start(1.0)
	end,
	on_metadata_inventory_take = function(pos)
		-- check whether the furnace is empty or not.
		minetest.get_node_timer(pos):start(1.0)
	end,
	on_blast = on_blast,
	
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
})

minetest.register_node(MOD_NAME..':coke_furnace_bricks', {
	description = 'Coke Furnace Bricks',
	tiles = aliska.make_brick_tiles('aliska_coke_furnace_bricks'),
	groups = {cracky = 3},
	sounds = default.node_sound_stone_defaults(),
	drop = MOD_NAME..':coke_furnace_bricks',
	on_construct = on_construct
})

minetest.register_craftitem(MOD_NAME..':coke', {
	description = 'Coal Coke',
	inventory_image = 'aliska_coke.png'
})

minetest.register_node(MOD_NAME..':coke_block', {
	description = 'Coal Coke Block',
	tiles = { 'aliska_coke_block.png' },
	drop = MOD_NAME..':coke_block',
	groups = {cracky = 3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft{
	type = 'fuel',
	recipe = MOD_NAME..':coke',
	burntime = 160,
}

aliska.register_craft(
	MOD_NAME..':coke_furnace_bricks 9',
	{1, 2, 1, 2, 1, 2, 1, 2, 1},
	{'group:sand', 'default:clay_brick'}
)
aliska.register_craft(
	MOD_NAME..':coke_block',
	{1, 1, 1, 1, 1, 1, 1, 1, 1},
	{ MOD_NAME..':coke' }
)
aliska.register_craft(
	MOD_NAME..':coke 9',
	{1},
	{ MOD_NAME..':coke_block' }
)

minetest.register_chatcommand('debug', {
	func = function(name)
		local player = minetest.get_player_by_name(name)
		local inv = player:get_inventory()

		if inv:room_for_item('main', 'default:coal_lump 99') then
			inv:add_item('main', 'default:coal_lump 99')
		end
	end
})
