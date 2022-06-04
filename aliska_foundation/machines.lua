function aliska.create_machine(form_callback, def)
	def = def or {}
	def.time_dummy = def.time_dummy or 10
	def.outputs = def.outputs or 1
	def.inputs = def.inputs or 1

	local machine = {
		recipes = {},
		times = {},
	}

	function machine:register_craft(input, output, time)
		time = time or def.time_dummy
		self.recipes[input] = output
		self.times[input] = time
	end

	function machine.get_form(time, total)
		return form_callback(time, total)
	end

	function machine:get_callbacks()
		function after_place_node(pos)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
	
			meta:set_string('dst', '')
			meta:set_int('timer', 1)
			meta:set_int('total', 1)
	
			inv:set_size('src', 1)
			inv:set_size('dst', 3)

			meta:set_string(
				'formspec',
				self.get_form(meta:get_string('timer'), meta:get_string('total'))
			)
		end
	
		function on_rightclick(pos)
			local meta = minetest.get_meta(pos)

			minetest.debug(aliska.serialize(pos))
			minetest.debug(self.get_form(meta:get_string('timer'), meta:get_string('total')))
	
			meta:set_string(
				'formspec',
				self.get_form(meta:get_string('timer'), meta:get_string('total'))
			)
		end
	
		function on_receive_fields(pos, formname, fields)
			if fields.quit then return end
	
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
	
			if meta:get_string('dst') == '' then
				local src_stack = inv:get_list('src')
				local item_name = src_stack[1]:get_name()
				local output = self.recipes[item_name]
	
				if output then
					meta:set_int('timer', self.times[item_name])
					meta:set_int('total', self.times[item_name])
					meta:set_string('dst', output)
					src_stack[1]:take_item(1)
					inv:set_list('src', src_stack)
					meta:set_string(
						'formspec',
						self.get_form(meta:get_string('timer'), meta:get_int('total'))
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
					self.get_form(meta:get_string('timer'), meta:get_int('total'))
				)
			end
		end
	
		function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count)
			if to_list == 'dst' then return 0 end
	
			return count
		end
	
		function allow_metadata_inventory_put(pos, list_name, index, stack)
			if list_name == 'dst' then return 0 end
	
			return stack:get_count()
		end
	
		function can_dig(pos, player)
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

		return after_place_node, on_rightclick, on_receive_fields,
		allow_metadata_inventory_move, allow_metadata_inventory_put
	end

	return machine
end
