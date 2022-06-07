local Set = aliska.Set
local c = aliska.c
local C = aliska.C

local registered_metals_tools = {'steel', 'bronze'}
local registered_tools_set = Set(registered_metals_tools)
local tools = { 'axe', 'sword', 'shovel', 'pickaxe' }
local tools_capabilities = {}

-- metal name = { mining Level, mining speed, uses, damage }
local tools_data = {
	tin = {1, 3, 2, 2},
	gold = {1, 3, 2, 2},
	lead = {1, 0, 10, 2},
	iron = {2, 4, 15, 4},
	zinc = {2, 5, 10, 4},
	brass = {1, 4, 15, 4},
	monel = {1, 4, 10, 2},
	copper = {2, 3, 5, 2},
	bronze = {2, 4, 25, 4},
	nickel = {2, 4, 15, 4},
	invar = {3, 4.5, 17, 5},
	steel = {3, 5.5, 30, 5},
	silver = {1, 5.5, 2, 2},
	nitinol = {2, 5, 10, 3},
	electrum = {1, 3, 4, 2},
	titanium = {3, 5, 17, 5},
	quartz = {3, 5.5, 30, 5},
	cast_iron = {2, 4, 15, 4},
	aluminium = {2, 4, 10, 2},
}
local tools_recipes = {
	axe = {1, 1, 0, 1, 2, 0, 0, 2, 0},
	sword = {0, 1, 0, 0, 1, 0, 0, 2, 0},
	shovel = {0, 1, 0, 0, 2, 0, 0, 2, 0},
	pickaxe = {1, 1, 1, 0, 2, 0, 0, 2, 0},
}

local function pickaxe_data(mining_level, mining_speed)
	local one, two, three = 4.5, 4.5, 4.5

	if mining_level <= 0 then
		return { [1]=one, [2]=two, [3]=three }, 1
	else
		three = -mining_speed / 3 + 3
	end

	if mining_level >= 2 then
		two = -mining_speed / 3 + 3.5
	end

	if mining_level >= 3 then
		one = -mining_speed / 3 + 4
	end

	return { [1]=one, [2]=two, [3]=three }, mining_level
end

local function Tool_capabilities(tool_group, times, uses, maxlevel, damage)
	return {
		full_punch_interval = 1.1,
		max_drop_level = 1,
		groupcaps = {
			[tool_group] = {times = times, uses = 2 * uses, maxlevel = maxlevel},
		},
		damage_groups = {fleshy = damage},
	}
end

local function Tool_data(item, mining_level, mining_speed, uses, damage)
	if item == 'sword' then
		return Tool_capabilities('snappy', { [1]=4.5, [2]=4.5, [3]=4.5 }, uses, 1, damage + 2)
	elseif item == 'hoe' then
		return Tool_capabilities('snappy', { [1]=4.5, [2]=4.5, [3]=4.5 }, uses, 1, damage - 1)
	elseif item == 'shovel' then
		local time, mining_level = pickaxe_data(mining_level, mining_speed + 3)

		return Tool_capabilities('crumbly', time, uses, mining_level, damage)
	elseif item == 'axe' then
		local time, mining_level = pickaxe_data(mining_level, mining_speed)

		return Tool_capabilities('choppy', time, uses, mining_level + 3, damage + 1)
	elseif item == 'pickaxe' then
		local time, mining_level = pickaxe_data(mining_level, mining_speed)

		return Tool_capabilities('cracky', time, uses, mining_level, damage)
	end
end

local function register_tool(metal_name, tool, definition)
	local tool_name = MOD_NAME..':'..metal_name..'_'..tool

	minetest.register_tool(tool_name, {
		description = C(metal_name, ' '..c(tool)),
		inventory_image = 'aliska_'..metal_name..'_'..tool..'.png',
		tool_capabilities = definition,
		groups = {[tool] = 1},
		punch_atack_uses = 20,
	})

	return tool_name
end

function aliska.register_tools(metal_name, items_name)
	if not registered_tools_set[metal_name] then
		for _, tool in ipairs(tools) do
			local data = tools_data[metal_name]
			local tool_name = register_tool(metal_name, tool, Tool_data(
				tool,
				data[1],
				data[2],
				data[3],
				data[4]
			))

			aliska.register_craft(
				tool_name,
				tools_recipes[tool],
				{ items_name['ingot'], 'group:stick' }
			)
		end
	end
end

minetest.register_on_mods_loaded(function()
	for _, metal in ipairs(registered_metals_tools) do 
		for _, tool in ipairs(tools) do
			local data = tools_data[metal]
			local mod = 'default:'
			local texture

			if tool == 'pickaxe' then
				tool = 'pick'
				texture = 'pickaxe'
			elseif tool == 'hoe' then
				mod = 'farming:'
			elseif tool == 'shovel' then
				minetest.override_item(
					mod..'shovel_'..metal,
					{
						wield_image = 'aliska_'..metal..'_shovel.png'
					}
				)
			end

			minetest.override_item(
				mod..tool..'_'..metal, 
				{
					tool_capabilities = Tool_data(tool, data[1], data[2], data[3], data[4]),
					inventory_image = 'aliska_'..metal..'_'..(texture or tool)..'.png',
				}
			)
		end
	end

	for _, tool in ipairs(tools) do
		local mod = 'default:'
		local texture

		if tool == 'pickaxe' then
			tool = 'pick'
			texture = 'pickaxe'
		elseif tool == 'hoe' then
			mod = 'farming:'
		elseif tool == 'shovel' then
			minetest.override_item(
				'default:shovel_mese',
				{
					wield_image = 'aliska_mese_shovel.png'
				}
			)
			minetest.override_item(
				'default:shovel_diamond',
				{
					wield_image = 'aliska_diamond_shovel.png'
				}
			)
		end

		minetest.override_item(
			mod..tool..'_mese', 
			{
				inventory_image = 'aliska_mese_'..(texture or tool)..'.png',
			}
		)
		minetest.override_item(
			mod..tool..'_diamond', 
			{
				inventory_image = 'aliska_diamond_'..(texture or tool)..'.png',
			}
		)
	end
end)

for _, tool in ipairs(tools) do
	local data = tools_data['quartz']
	local tool_name = register_tool('quartz', tool, Tool_data(
		tool,
		data[1],
		data[2],
		data[3],
		data[4]
	))

	aliska.register_cooking(MOD_NAME..':nitinol_'..tool, MOD_NAME..':nitinol_'..tool)

	aliska.register_craft(
		tool_name,
		tools_recipes[tool],
		{ MOD_NAME..':gems_quartz', 'group:stick' }
	)
end

minetest.register_chatcommand('take', {
	func = function(name)
		local player = minetest.get_player_by_name(name)
		local inv = player:get_inventory()

		inv:add_item('main', MOD_NAME..':nitinol_pickaxe 1 23232')

		return true
	end
})
