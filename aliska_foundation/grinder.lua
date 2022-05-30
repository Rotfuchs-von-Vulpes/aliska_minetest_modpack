grinder = {
	recipes = {},
	times = {},
}

function grinder.get_form(time, total)
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

function aliska.register_grinder_craft(input, output, time)
	time = time or 10

	grinder.recipes[input] = output
	grinder.times[input] = time
end

minetest.register_node(MOD_NAME..':manual_grinder', {
	description = 'Manual Grinder',
	tiles = {
		'aliska_grinder_top.png',
		'aliska_grinder_side.png',
		'aliska_grinder_side.png',
		'aliska_grinder_side.png',
		'aliska_grinder_side.png',
		'aliska_grinder_front.png',
	},
	groups = { cracky = 1 },
	drop = MOD_NAME..':manual_grinder',
	paramtype2 = 'facedir',
	after_place_node = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		meta:set_string('dst', '')
		meta:set_int('timer', 1)
		meta:set_int('total', 1)

		inv:set_size('src', 1)
		inv:set_size('dst', 3)
	end,
	on_rightclick = function(pos)
		local meta = minetest.get_meta(pos)

		meta:set_string(
			'formspec', 
			grinder.get_form(meta:get_string('timer'), meta:get_string('total')))
	end,
	on_receive_fields = function(pos, formname, fields)
		if fields.quit then return end

		-- infotext

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
					grinder.get_form(meta:get_string('timer'), meta:get_int('total'))
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
				grinder.get_form(meta:get_string('timer'), meta:get_int('total'))
			)
		end
	end,
	allow_metadata_inventory_move = 
	function(pos, from_list, from_index, to_list, to_index, count)
		if to_list == 'dst' then return 0 end

		return count
	end,
	allow_metadata_inventory_put = function(pos, list_name, index, stack)
		if list_name == 'dst' then return 0 end

		return stack:get_count()
	end,
	can_dig = function(pos, player)
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
})

minetest.register_node(MOD_NAME..':lever', {
	description = 'Rotate Lever',
	tiles = {'aliska_grinder_side.png'},
	groups = { cracky = 1 },
	drop = MOD_NAME..':lever',
	paramtype2 = "degrotate",
	drawtype = 'plantlike',
	walkable = false,
	sunlight_propagates = true,
	on_rightclick = function(pos, node)
		node.param2 = node.param2 + 10
		minetest.swap_node(pos, node)
	end
})

aliska.register_grinder_craft('default:gravel', 'default:flint')
aliska.register_grinder_craft('default:stone', 'default:gravel')
aliska.register_grinder_craft('default:desert_stone', 'default:gravel')
aliska.register_grinder_craft('default:cobble', 'default:silver_sand')
aliska.register_grinder_craft('default:desert_cobble', 'default:silver_sand')

aliska.register_craft(
	MOD_NAME..':manual_grinder',
	{ 1, 1, 1, 1, 2, 1, 1, 1, 1 },
	{ 'default:cobble', MOD_NAME..':gems_quartz' }
)