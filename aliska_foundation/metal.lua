local Set = aliska.Set
local c = aliska.c
local C = aliska.C

local items = { 'plate', 'gear', 'powder', 'tiny_powder', 'nugget' }
local items_name = {}

local function register_item(metal_name, item)
	minetest.register_craftitem(MOD_NAME..':'..metal_name..'_'..item, {
		description = C(metal_name, ' '..c(item)),
		inventory_image = 'aliska_'..metal_name..'_'..item..'.png',
	})
end

function aliska.register_metal(metal_name)
	local mat

	for _, item in ipairs(items) do
		items_name[item] = MOD_NAME..':'..metal_name..'_'..item
		register_item(metal_name, item)
	end

	if not registered_metals_set[metal_name] then
		items_name['ingot'] = MOD_NAME..':'..metal_name..'_ingot'
		items_name['block'] = MOD_NAME..':'..metal_name..'_block'
		register_item(metal_name, 'ingot')
	
		minetest.register_node(items_name['block'], {
			description = C(metal_name, ' Block'),
			tiles = { 'aliska_'..metal_name..'_block.png' },
			drop = items_name['block'],
			groups = { cracky = 1, node = 1 }
		})

		aliska.register_craft(
			items_name['block'],
			{ 1, 1, 1, 1, 1, 1, 1, 1, 1 },
			{ items_name['ingot'] }
		)
	else
		items_name['ingot'] = 'default:'..metal_name..'_ingot'
		items_name['block'] = 'default:'..metal_name..'block'
	end

	aliska.register_craft(
		items_name['gear'],
		{ 0, 1, 0, 1, 2, 1, 0, 1, 0 },
		{ items_name['plate'], MOD_NAME..':iron_ingot' }
	)
	aliska.register_craft(items_name['nugget']..' 9', {1}, {items_name['ingot']})
	aliska.register_craft(
		items_name['ingot'],
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ items_name['nugget'] }
	)
	aliska.register_craft(
		items_name['ingot']..' 9',
		{1},
		{items_name['block']}
	)
	aliska.register_craft(
		items_name['powder'],
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ items_name['tiny_powder'] }
	)
	aliska.register_craft(
		items_name['tiny_powder']..' 9',
		{ 1 },
		{ items_name['powder'] }
	)

	aliska.register_cooking(items_name['tiny_powder'], items_name['nugget'])
	aliska.register_cooking(items_name['powder'], items_name['ingot'])

	aliska.register_hammer_craft(items_name['ingot'], items_name['plate'])

	return items_name
end

minetest.register_on_mods_loaded(function()
	for _, metal in ipairs(registered_metals) do
		minetest.override_item(
			'default:'..metal..'block',
			{ tiles = {'aliska_'..metal..'_block.png'} }
		)
		minetest.override_item(
			'default:'..metal..'_ingot',
			{ inventory_image = 'aliska_'..metal..'_ingot.png' }
		)
	end

	local mat1 = 'default:copper_ingot'
	local mat2 = 'default:tin_ingot'
	minetest.clear_craft({
		output = 'default:bronze_ingot 9',
		recipe = {
			{ mat1, mat1, mat1 },
			{ mat1, mat2, mat1 },
			{ mat1, mat1, mat1 }
		},
	})
	minetest.clear_craft({
		output = 'default:steel_ingot',
		type = 'cooking',
		recipe = 'default:iron_lump',
	})
	aliska.register_cooking('default:iron_lump', MOD_NAME..':iron_ingot')
end)

aliska.register_alloy(
	{ MOD_NAME..':copper_powder', MOD_NAME..':zinc_powder' },
	{ 2, 1 },
	MOD_NAME..':brass_powder'
)

aliska.register_alloy(
	{ MOD_NAME..':copper_powder', MOD_NAME..':tin_powder' },
	{ 3, 1 },
	MOD_NAME..':bronze_powder'
)

aliska.register_alloy(
	{ MOD_NAME..':silver_powder', MOD_NAME..':gold_powder' },
	{ 1, 1 },
	MOD_NAME..':electrum_powder'
)

aliska.register_alloy(
	{ MOD_NAME..':titanium_powder', MOD_NAME..':nickel_powder' },
	{ 1, 1 },
	MOD_NAME..':nitinol_powder'
)

aliska.register_alloy(
	{ MOD_NAME..':nickel_powder', MOD_NAME..':copper_powder' },
	{ 3, 1 },
	MOD_NAME..':monel_powder'
)

aliska.register_alloy(
	{ MOD_NAME..':nickel_powder', MOD_NAME..':iron_powder' },
	{ 1, 3 },
	MOD_NAME..':invar_powder'
)
