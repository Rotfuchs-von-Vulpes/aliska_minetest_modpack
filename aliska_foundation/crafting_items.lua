local c = aliska.c
local craft_tools = {}
local output_items = {}
local craft_tools_map = {}
local serialize = aliska.serialize

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	local output = itemstack:get_name()
	
	if not craft_tools_map[output] then return end

	local list = craft_inv:get_list('craft')
	local hammer
	local index
	for i, itemstack in ipairs(old_craft_grid) do
		if itemstack:get_name() == craft_tools_map[output] then
			index, hammer = i, itemstack
			break
		end
	end

	if not hammer then return end

	hammer:add_wear(600)
	list[index]:replace(hammer)
	craft_inv:set_list('craft', list)
end)

local function register_crafting_tool(item_name, recipe_definition)
	minetest.register_tool(MOD_NAME..':'..item_name, {
		description = c(item_name),
		inventory_image = 'aliska_'..item_name..'.png',
	})
	
	aliska.register_craft(
		MOD_NAME..':'..item_name,
		recipe_definition[1],
		recipe_definition[2]
	)

	table.insert(craft_tools, MOD_NAME..':'..item_name)

	return function(input, output)
		minetest.register_craft{
			type = 'shapeless',
			output = output,
			recipe = { MOD_NAME..':'..item_name, input},
		}
		
		table.insert(output_items, output)
		craft_tools_map[ItemStack(output):get_name()] = MOD_NAME..':'..item_name
	end
end

aliska.register_hammer_craft = register_crafting_tool('forge_hammer', {
	{ 0, 1, 1, 2, 2, 1, 0, 1, 1 },
	{ MOD_NAME..':iron_ingot', 'group:stick' },
})
