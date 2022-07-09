local c = aliska.c

local function Cluster(scarcity, num_ores, size)
	return { scarcity = scarcity, num_ores = num_ores, size = size }
end
function Metal_definition(lump, size, num_ores, scarcity)
	return {
		lump = lump,
		size = size,
		num_ores = num_ores,
		scarcity = scarcity,
	}
end
function Ore_definitions(drop, ranges, sizes, num_ores, scarcities)
	local clusters = {}

	for i, size in ipairs(sizes) do
		clusters[i] = Cluster(scarcities[i], num_ores[i], sizes[i])
	end

	return {
		drop = drop,
		ranges = ranges,
		clusters = clusters
	}
end

local new_gems = { 'amethyst', 'fluorite', 'ruby', 'emerald', 'sapphire' }
local new_metals = {
	titanium = Metal_definition('Limenite', 2, 2, 25),
	electrum = Metal_definition('Electrum', 2, 2, 30),
	aluminium = Metal_definition('Bauxite', 2, 2, 8),
	nickel = Metal_definition('Garnierite', 2, 2, 7),
	zinc = Metal_definition('Spharelite', 3, 11, 9),
	lead = Metal_definition('Galena', 2, 2, 9),
}
local old_metals = {
	copper = Metal_definition('Chalcopyrite', 3, 12, 8),
	tin = Metal_definition('Cassiterite', 3, 12, 8),
	iron = Metal_definition('Hematite', 3, 10, 7),
	gold = Metal_definition('Gold', 2, 2, 20),
	coal = Metal_definition('Coal', 3, 8, 4),
}
local ores = {
	sulfur = Ore_definitions(
		'sulfur',
		{{ -2048, -31000 }, { -524, -2047 }},
		{5, 3},
		{30, 8},
		{12*12*12, 8*8*8}
	),
	quartz = Ore_definitions(
		'gems_quartz',
		{{ -256, -31000 }, { -256, -31000 }},
		{3, 3},
		{6, 4},
		{15*15*15, 14*14*14}
	),
	borax = Ore_definitions(
		'gems_borax',
		{{ 64, -31000}, { 31000, 0 }},
		{3, 3},
		{4, 2},
		{14*14*14, 15*15*15}
	),
	graphite = Ore_definitions(
		'graphite',
		{{ -2048, -31000 }, { -256, -2047 }},
		{3, 3},
		{15, 4},
		{12*12*12, 8*8*8}
	),
	salt = Ore_definitions(
		'salt', 
		{{ 64, -31000}, { 31000, 0 }},
		{3, 3}, 
		{4, 2},
		{12*12*12, 13*13*13}
	),
}

local is_smelting = aliska.Set{
	'iron', 'copper', 'tin', 'gold', 'electrum', 'lead', 'nickel', 'zinc'
}

local function register_lump(name, description)
	local lump_name = 'aliska_foudation:'..name..'_lump'

	minetest.register_craftitem(lump_name, {
		description = description,
		inventory_image = 'aliska_raw_'..name..'.png',
	})

	if is_smelting[name] then
		aliska.register_cooking(lump_name, 'aliska_foudation:'..name..'_ingot')
		-- aliska.register_grinder_craft(lump_name, 'aliska_foudation:'..name..'_powder 2')
		-- aliska.register_grinder_craft('aliska_foudation:'..name..'_ingot', 'aliska_foudation:'..name..'_powder')
	elseif name ~= 'titanium' then
		-- blast_furnace:register_craft(lump_name, 'aliska_foudation:'..name..'_ingot')
	end

	return lump_name
end

local function atualize_lump(name, description)
	local lump_name = 'default:'..name..'_lump'

	minetest.override_item(lump_name, {
		description = description,
		inventory_image = 'aliska_raw_'..name..'.png',
	})

	return lump_name
end

local function register_ore_node(drop, name, mining_level, where_in, mining_type)
	local ore_name = 'aliska_foudation:'..where_in..'_with_'..name
	local mining_type = mining_type or 'cracky'
	local falling
	local sounds

	if mining_type == 'crumbly' then
		falling = 1
		sounds = default.node_sound_sand_defaults()
	else
		sounds = default.node_sound_stone_defaults()
	end

	minetest.register_node(ore_name, {
		description = c(name)..' Ore',
		tiles = { 'default_'..where_in..'.png^aliska_raw_'..name..'_ore.png' },
		groups = { [mining_type] = mining_level, falling_node = falling },
		drop = drop,
		sounds = sounds,
	})
end

local function atualize_ore_node(name)
	minetest.override_item('default:stone_with_'..name, {
		tiles = { 'default_stone.png^aliska_raw_'..name..'_ore.png' }
	})
end

for metal, ore_definition in pairs(new_metals) do
	local drop = register_lump(metal, ore_definition.lump)
	register_ore_node(drop, metal, 2, 'stone')
	register_ore_node(drop, metal, 2, 'desert_stone')
end

for metal, ore_definition in pairs(old_metals) do
	local drop = atualize_lump(metal, ore_definition.lump)
	register_ore_node(drop, metal, 2, 'desert_stone')
	atualize_ore_node(metal)
end

for ore, ore_definition in pairs(ores) do
	local drop = 'aliska_foudation:'..ore_definition.drop
	register_ore_node(drop, ore, 2, 'stone')
	register_ore_node(drop, ore, 2, 'desert_stone')
end

for _, gem in ipairs(new_gems) do
	local drop = 'aliska_foudation:gems_'..gem
	register_ore_node(drop, gem, 1, 'stone')
end

register_ore_node('aliska_foudation:niter', 'niter', 3, 'silver_sand', 'crumbly')
