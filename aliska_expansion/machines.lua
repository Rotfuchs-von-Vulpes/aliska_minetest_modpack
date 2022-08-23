function separate(stack)
	local arr = {}

	stack:gsub('%S+', function(str)
		arr[#arr+1] = str
	end)

	return arr
end

aliska.machines_methods = {
	combustion_on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		inv:set_list('src', 1)
		inv:set_list('dst', 1)
		inv:set_list('fuel', 1)
	end,
}

function aliska.create_process_machine(name, def)
	local machine = {
		active = def.active,
		inactive = def.inactive,
		recipes = {},
		outputs = {},
		recipe_map = {},
		times = {},
	}

	local swap_node = def.swap_node or function(pos, name)
		local node = minetest.get_node(pos)
		if node.name == name then
			return
		end
		node.name = name
		minetest.swap_node(pos, node)
	end

	for _, listname in ipairs(def.recipe_slots) do
		machine.recipe_map[listname] = {}
	end

	function machine:register_craft(input, output, time)
		time = time or def.default_time
		idx = #self.recipes + 1
		self.recipes[idx] = {}
		
		for listname, list in pairs(input) do
			local items = {}
			local count = {}

			for _, stack in ipairs(list) do
				local arr = separate(stack)
				local item, num = arr[1], arr[2]

				items[#items+1], count[item] = item, num

				if self.recipe_map[listname][item] then
					local len = #self.recipe_map[listname][item]
					self.recipe_map[listname][item][len+1] = idx
				else
					self.recipe_map[listname][item] = {idx}
				end
			end

			self.recipes[idx][listname] = {items = items, count = count}
		end

		self.outputs[idx] = output
		self.times[idx] = time
	end

	function machine:match_craft(input)
		local idxs = {}
		local i = 1
		
		for listname, list in pairs(input) do
			local is_empty = true

			idxs[i] = {}

			for _, item in ipairs(list) do
				if item ~= '' then
					is_empty = false

					idxs[i][item] = {}

					if not self.recipe_map[listname][item] then
						return false
					end

					for _, idx in ipairs(self.recipe_map[listname][item]) do
						table.insert(idxs[i][item], idx)
					end
				end
			end

			if is_empty then return false end

			i = i + 1
		end
		
		local possibles_idxs = {}
		for _, list in ipairs(idxs) do
			local arr_list = {}

			for _, arr in pairs(list) do
				table.insert(arr_list, arr)
			end

			table.insert(possibles_idxs, aliska.find_many_repeted(arr_list))
		end

		local final_idxs = aliska.find_many_repeted(possibles_idxs)

		if #final_idxs > 1 then
			return false
		end

		local final_idx = final_idxs[1]

		local ingredients = self.recipes[final_idx]

		for listname, list in pairs(ingredients) do
			local ingredients_set = aliska.Set(input[listname])

			for _, item in ipairs(list.items) do
				if not ingredients_set[item] then
					return false
				end
			end
		end

		return self.outputs[final_idx]
	end

	machine.on_construct = def.on_construct

	machine.can_dig = def.can_dig
	
	machine.allow_metadata_inventory_put = def.allow_metadata_inventory_put

	function machine.allow_metadata_inventory_move(pos,
		from_list, from_index, to_list, to_index)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local stack = inv:get_stack(from_list, from_index)
	
		return machine.allow_metadata_inventory_put(pos, to_list, to_index, stack)
	end

	function machine.inventory_interaction(pos)
		minetest.get_node_timer(pos):start(0.0)
	end

	function machine:get_node_timer()
		return function(pos)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()

			local src_list_string = {}

			local i = 1
			for _, slot in ipairs(inv:get_list('src')) do
				local str = slot:to_string()

				if str ~= '' then
					src_list_string[i] = str
					i = i + 1
				end
			end
			
			minetest.debug(aliska.serialize(
				debug_machine:match_craft{src = src_list_string}
			))

			return false
		end
	end

	return machine
end

function aliska.create_combustion_machine(
	name,
	machine_active,
	machine_inactive,
	dummy_time,
	swap_node,
	is_fuel,
	update_info
)
	local machine = {
		active = machine_active,
		inactive = machine_inactive,
		recipes = {},
		times = {},
	}

	swap_node = swap_node or function(pos, name)
		local node = minetest.get_node(pos)
		if node.name == name then
			return
		end
		node.name = name
		minetest.swap_node(pos, node)
	end

	is_fuel = is_fuel or function(stack)
		return minetest.get_craft_result({
			method='fuel', width=1, items={stack}
		}).time ~= 0
	end

	function machine:register_craft(input, output, time)
		time = time or dummy_time
		self.recipes[input] = output
		self.times[input] = time
	end

	function machine.can_dig(pos, player)
		local player_inv = player:get_inventory()
		local node_inv = minetest.get_meta(pos):get_inventory()
	
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

	function machine.allow_metadata_inventory_put(pos, listname, index, stack)
		local item = stack:get_name()
	
		if listname == 'fuel' then
			if is_fuel(stack) then
				return stack:get_count()
			else
				return 0
			end
		elseif listname == 'src' then
			if machine.recipes[item] then
				return stack:get_count()
			else
				return 0 
			end
		else
			return 0
		end
	end

	function machine.allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local stack = inv:get_stack(from_list, from_index)
	
		return machine.allow_metadata_inventory_put(pos, to_list, to_index, stack)
	end

	function machine.inventory_interaction(pos)
		minetest.get_node_timer(pos):start(1.0)
	end

	function machine:get_node_timer()
		return function(pos)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			local srclist = inv:get_list('src')
			local dstlist = inv:get_list('dst')
			local fuellist = inv:get_list('fuel')
		
			local src = meta:get_string('src')
			local dst = meta:get_string('dst')
		
			if src == '' then
				src = srclist[1]:get_name()
			end
		
			if dst == '' then
				dst = self.recipes[src] or ''
			end
		
			local fuel_percent = meta:get_int('fuel_percent')
			local item_percent = meta:get_int('item_percent')
			local infotext
			local result = false
		
			local cooking = meta:get_int('cooking')
			local time = meta:get_int('time')
			local fuel_time = meta:get_int('fuel')
			local fuel_total = meta:get_int('fuel_total')
			local time_total = meta:get_int('time_total')

			if time_total == 0 then
				time_total = self.times[src]
			end
		
			function stop_cook()
				item_percent = 0
				infotext = name..' inactive'
				meta:set_int('item_percent', 0)
				meta:set_int('cooking', 0)
				meta:set_int('time', 0)
				src = ''
				dst = ''
				meta:set_string('src', '')
				meta:set_string('dst', '')
			end
		
			function start_cook()
				if self.recipes[src] then
					srclist[1]:take_item(1)
					inv:set_list('src', srclist)

					infotext = name..' active\nItem: 0%, Fuel: '..fuel_percent

					meta:set_int('cooking', 1)
					meta:set_int('time', 0)
					meta:set_string('src', src)
					meta:set_string('dst', dst)
					result = true
				else
					stop_cook()
				end
			end
		
			function start_fuel()
				local fuel, afterfuel = minetest.get_craft_result({
					method = 'fuel', width = 1, items = fuellist
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
					swap_node(pos, machine.active)
				else
					swap_node(pos, machine.inactive)
				end
			end
		
			function on_cooked()
				item_percent = 0
				meta:set_int('item_percent', 0)
		
				if inv:room_for_item('dst', dst) then
					inv:add_item('dst', dst)
					src = ''
					dst = ''
					meta:set_string('src', '')
					meta:set_string('dst', '')
					return true
				else
					return false
				end
			end
		
			if fuel_time > 0 then
				if fuel_time <= 0 then return end
				fuel_time = fuel_time - 1
				fuel_percent = fuel_time / fuel_total * 100
				meta:set_int('fuel', fuel_time)
				meta:set_int('fuel_percent', fuel_percent)
				result = true
			else
				if self.recipes[src] or cooking == 1 then
					start_fuel()
				else
					swap_node(pos, machine.inactive)
				end
			end
		
			if cooking == 1 then
				if time >= time_total then
					if on_cooked() and fuel_time > 0 then
						start_cook()
					end
				elseif fuel_time > 0 then
					time = time + 1
					item_percent = time / time_total * 100
					meta:set_int('time', time)
					meta:set_int('item_percent', item_percent)
					result = true
				end
			elseif fuel_time > 0 then
				start_cook()
			end
		
			item_percent = math.floor(item_percent * 100) / 100
			fuel_percent = math.floor(fuel_percent * 100) / 100
			infotext = name..' active\nItem: '..item_percent..
			'%, fuel: '..fuel_percent..'%'
			update_info(pos, fuel_percent, item_percent, infotext)

			return result
		end
	end

	return machine
end

local function get_form()
	return 'size[9,8;]'..
	'list[context;src;2.75,1;1,1;0]'..
	'list[context;src;4,0.5;1,1;1]'..
	'list[context;src;5.25,1;1,1;2]'..
	'list[context;dst;4,2.5;1,1;]'..
	'list[current_player;main;0,4;9,4;]'..
	'listring[context;dst]'..
	'listring[current_player;main]'..
	'listring[context;src]'..
	'listring[current_player;main]'..
	default.get_hotbar_bg(0, 4)
end

debug_machine = aliska.create_process_machine('Debug machine', {
	src = 'item',
	dst = 'item',
	energy = 'item',
	recipe_slots = {'src', 'dst'},
})

debug_machine:register_craft(
	{src = {'aliska_foudation:copper_ingot 2', 'aliska_foudation:zinc_ingot'}},
	{dst = {'aliska_foudation:brass_ingot 3'}}
)
debug_machine:register_craft(
	{src = {'aliska_foudation:copper_ingot 3', 'aliska_foudation:tin_ingot'}},
	{dst = {'aliska_foudation:bronze_ingot 4'}}
)
debug_machine:register_craft(
	{src = {'aliska_foudation:silver_ingot', 'aliska_foudation:gold_ingot'}},
	{dst = {'aliska_foudation:electrum_ingot 2'}}
)
debug_machine:register_craft(
	{src = {'aliska_foudation:titanium_ingot', 'aliska_foudation:nickel_ingot'}},
	{dst = {'aliska_foudation:nitinol_ingot 2'}}
)
debug_machine:register_craft(
	{src = {'aliska_foudation:copper_ingot 3', 'aliska_foudation:nickel_ingot'}},
	{dst = {'aliska_foudation:monel_ingot 4'}}
)
debug_machine:register_craft(
	{src = {'aliska_foudation:iron_ingot 2', 'aliska_foudation:nickel_ingot'}},
	{dst = {'aliska_foudation:invar_ingot 3'}}
)

minetest.register_node('aliska_expansion:debug_machine', {
	description = 'Debug machine',
	tiles = {'aliska_grinder_side.png', 'aliska_bronze_block.png'},
	groups = { cracky = 1 },
	after_place_node = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
	
		inv:set_size('src', 3)
		inv:set_size('dst', 1)
	
		meta:set_string(
			'formspec',
			get_form()
		)
	end,
	on_metadata_inventory_move = debug_machine.inventory_interaction,
	on_metadata_inventory_put = debug_machine.inventory_interaction,
	on_metadata_inventory_take = debug_machine.inventory_interaction,
	on_timer = debug_machine:get_node_timer()
})
