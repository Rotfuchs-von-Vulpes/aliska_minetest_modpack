local function get_form(time, total)
	return 'size[9,8;]'..
	'list[context;src;2,1;1,1;]'..
	'list[context;dst;4,2;3,1;]'..
	'list[current_player;main;0,4;9,4;]'..
	'button[4.5,0;2,1;grind;grind]'..
	'image[3.4,1;4,1;aliska_grinder_gui_on.png^[lowpart:'..
	(time/total*100)..':aliska_grinder_gui_off.png]'..
	'listring[context;dst]'..
	'listring[current_player;main]'..
	'listring[context;src]'..
	'listring[current_player;main]'..
	default.get_hotbar_bg(0, 4)
end

grinder = {
	recipes = {},
	times = {},
}

local function after_place_node(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	meta:set_string('dst', '')
	meta:set_int('timer', 1)
	meta:set_int('total', 1)

	inv:set_size('src', 1)
	inv:set_size('dst', 3)

	meta:set_string(
		'formspec',
		get_form(meta:get_string('timer'), meta:get_string('total'))
	)
end

function aliska.register_grinder_craft(input, output, time)
	time = time or 10
	grinder.recipes[input] = output
	grinder.times[input] = time
end

local function on_receive_fields(pos, formname, fields)
	if fields.quit then return end

	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	if meta:get_string('dst') == '' then
		local src_stack = inv:get_list('src')
		local item_name = src_stack[1]:get_name()
		local output = grinder.recipes[item_name]

		if output then
			meta:set_int('timer', grinder.times[item_name])
			meta:set_int('total', grinder.times[item_name])
			meta:set_string('dst', output)
			src_stack[1]:take_item(1)
			inv:set_list('src', src_stack)
			meta:set_string(
				'formspec',
				get_form(meta:get_string('timer'), meta:get_int('total'))
			)
		end
	else
		local timer = meta:get_int('timer')
		
		if timer > 0 then
			meta:set_int('timer', timer - 1)
		else
			local output = meta:get_string('dst')

			if inv:room_for_item('dst', output) then
				inv:add_item('dst', output)
				meta:set_string('dst', '')
				meta:set_int('timer', 1)
				meta:set_int('total', 1)
			end
		end

		meta:set_string(
			'formspec',
			get_form(meta:get_string('timer'), meta:get_int('total'))
		)
	end
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count)
	if to_list == 'dst' then return 0 end

	return count
end

local function allow_metadata_inventory_put(pos, list_name, index, stack)
	if list_name == 'dst' then return 0 end

	return stack:get_count()
end

local function can_dig(pos, player)
	local player_inv = player:get_inventory()
	local node_inv = minetest.get_meta(pos):get_inventory()

	local src = node_inv:get_list('src')[1]
	if player_inv:room_for_item('main', src) then
		player_inv:add_item('main', src)
	else 
		return false
	end

	local dst_list = node_inv:get_list('dst')
	for _, dst in ipairs(dst_list) do
		if player_inv:room_for_item('main', dst) then
			player_inv:add_item('main', dst)
		else 
			return false
		end
	end

	return true
end

minetest.register_node('aliska_expanse:manual_grinder', {
	description = 'Manual Grinder',
	tiles = {
		'aliska_grinder_top.png',
		'aliska_grinder_side.png',
		'aliska_grinder_side.png',
		'aliska_grinder_side.png',
		'aliska_grinder_side.png',
		'aliska_grinder_front.png',
	},
	groups = { cracky = 1, aliska_receptor_kinetics = 1 },
	drop = 'aliska_expanse:manual_grinder',
	paramtype2 = 'facedir',
	after_place_node = after_place_node,
	on_receive_fields = on_receive_fields,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_put = allow_metadata_inventory_put
})

aliska.register_grinder_craft('default:gravel', 'default:flint')
aliska.register_grinder_craft('default:stone', 'default:gravel')
aliska.register_grinder_craft('default:desert_stone', 'default:gravel')
aliska.register_grinder_craft('default:cobble', 'default:silver_sand')
aliska.register_grinder_craft('default:desert_cobble', 'default:silver_sand')

aliska.register_craft(
	'aliska_expanse:manual_grinder',
	{ 1, 1, 1, 1, 2, 1, 1, 1, 1 },
	{ 'default:cobble', 'aliska_foudation:gems_quartz' }
)

local metals = {
	iron = 'aliska_foudation:iron_lump',
	copper = 'default:copper_lump',
	tin = 'default:tin_lump',
	gold = 'default:gold_lump',
	electrum = 'aliska_foudation:electrum_lump',
	lead = 'aliska_foudation:lead_lump',
	nickel = 'aliska_foudation:nickel_lump',
	zinc = 'aliska_foudation:zinc_lump'
}
for metal, raw in pairs(metals) do 
	aliska.register_grinder_craft(raw, 'aliska_foudation:'..metal..'_powder 2')
end

aliska.register_grinder_craft('default:coal_lump', 'aliska_foudation:coal_powder')
aliska.register_grinder_craft('default:silver_sand', 'aliska_foudation:silica 9')
aliska.register_grinder_craft('aliska_foudation:gems_quartz', 'aliska_foudation:silica')
