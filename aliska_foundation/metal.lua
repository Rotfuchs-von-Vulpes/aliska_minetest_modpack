local Set = aliska.Set
local c = aliska.c
local C = aliska.C

local items = { 'plate', 'gear', 'powder', 'tiny_powder', 'nugget' }
local items_name = {}

local function register_item(metal_name, item)
	minetest.register_craftitem('aliska_foudation:'..metal_name..'_'..item, {
		description = C(metal_name, ' '..c(item)),
		inventory_image = 'aliska_'..metal_name..'_'..item..'.png',
	})
end

function aliska.register_metal(metal_name)
	local mat

	for _, item in ipairs(items) do
		items_name[item] = 'aliska_foudation:'..metal_name..'_'..item
		register_item(metal_name, item)
	end

	if not registered_metals_set[metal_name] then
		items_name['ingot'] = 'aliska_foudation:'..metal_name..'_ingot'
		items_name['block'] = 'aliska_foudation:'..metal_name..'_block'
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
		{ items_name['plate'], 'aliska_foudation:iron_ingot' }
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

	-- aliska.register_hammer_craft(items_name['ingot'], items_name['plate'])

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
	aliska.register_cooking('default:iron_lump', 'aliska_foudation:iron_ingot')
end)

aliska.register_alloy(
	{ 'aliska_foudation:copper_powder', 'aliska_foudation:zinc_powder' },
	{ 2, 1 },
	'aliska_foudation:brass_powder'
)

aliska.register_alloy(
	{ 'aliska_foudation:copper_powder', 'aliska_foudation:tin_powder' },
	{ 3, 1 },
	'aliska_foudation:bronze_powder'
)

aliska.register_alloy(
	{ 'aliska_foudation:silver_powder', 'aliska_foudation:gold_powder' },
	{ 1, 1 },
	'aliska_foudation:electrum_powder'
)

aliska.register_alloy(
	{ 'aliska_foudation:titanium_powder', 'aliska_foudation:nickel_powder' },
	{ 1, 1 },
	'aliska_foudation:nitinol_powder'
)

aliska.register_alloy(
	{ 'aliska_foudation:nickel_powder', 'aliska_foudation:copper_powder' },
	{ 3, 1 },
	'aliska_foudation:monel_powder'
)

aliska.register_alloy(
	{ 'aliska_foudation:nickel_powder', 'aliska_foudation:iron_powder' },
	{ 1, 3 },
	'aliska_foudation:invar_powder'
)
