
-- energy = none|fuel|liquid_fuel|electricity|solar
-- src = none,item,fluid,electricity
-- dst = item,fluid,electricity
function aliska.create_machine(name, def)

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
			method="fuel", width=1, items={stack}
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
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
	
		if listname == "fuel" then
			if is_fuel(stack) then
				return stack:get_count()
			else
				return 0
			end
		elseif listname == "src" then
			if machine.recipes[item] then
				return stack:get_count()
			else
				return 0 
			end
		elseif listname == "dst" then
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