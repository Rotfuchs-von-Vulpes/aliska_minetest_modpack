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
		{{ 0, -31000 }, { 64, -31000}, { 31000, 0 }},
		{3, 3, 3},
		{6, 4, 2},
		{15*15*15, 14*14*14, 15*15*15}
	),
	borax = Ore_definitions(
		'gems_borax',
		{{ 0, -31000 }, { 64, -31000}, { 31000, 0 }},
		{3, 3, 3},
		{6, 4, 2},
		{15*15*15, 14*14*14, 15*15*15}
	),
	graphite = Ore_definitions(
		'graphite',
		{{ -2048, -31000 }, { -524, -2047 }},
		{3, 3},
		{15, 4},
		{12*12*12, 8*8*8}
	),
	salt = Ore_definitions(
		'salt', 
		{{ 0, -31000 }, { 64, -31000}, { 31000, 0 }},
		{3, 3, 3}, 
		{6, 4, 2},
		{13*13*13, 12*12*12, 13*13*13}
	),
}

local is_smelting = aliska.Set{
	'iron', 'copper', 'tin', 'gold', 'electrum', 'lead', 'nickel', 'zinc'
}

local function register_lump(name, description)
	local lump_name = MOD_NAME..':'..name..'_lump'

	minetest.register_craftitem(lump_name, {
		description = description,
		inventory_image = 'aliska_raw_'..name..'.png',
	})

	if is_smelting[name] then
		aliska.register_cooking(lump_name, MOD_NAME..':'..name..'_ingot')
		aliska.register_grinder_craft(lump_name, MOD_NAME..':'..name..'_powder 2')
		aliska.register_grinder_craft(MOD_NAME..':'..name..'_ingot', MOD_NAME..':'..name..'_powder')
	elseif name ~= 'titanium' then
		blast_furnace:register_craft(lump_name, MOD_NAME..':'..name..'_ingot')
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

local function register_ore_node(drop, name, mining_level, where_in )
	local ore_name = MOD_NAME..':'..where_in..'_with_'..name

	minetest.register_node(ore_name, {
		description = c(name)..' Ore',
		tiles = { 'default_'..where_in..'.png^aliska_raw_'..name..'_ore.png' },
		groups = { cracky = mining_level },
		drop = drop,
		sounds = default.node_sound_stone_defaults(),
	})

	return ore_name
end

local function atualize_ore_node(name)
	minetest.override_item('default:stone_with_'..name, {
		tiles = { 'default_stone.png^aliska_raw_'..name..'_ore.png' }
	})
end

local function register_generation(ore, wherein, cluster, range)
	minetest.register_ore{
		ore_type = 'scatter',
		ore = ore,
		wherein = wherein,
		clust_scarcity = cluster.scarcity,
		clust_num_ores = cluster.num_ores,
		clust_size = cluster.size,
		y_max = range[1],
		y_min = range[2],
	}
end

local function register_generations(ore, wherein, clusters, ranges)
	for i, range in ipairs(ranges) do
		register_generation(ore, wherein, clusters[i], range)
	end
end

for metal, ore_definition in pairs(new_metals) do 
	local ranges = { { 0, -31000 }, { 64, -31000 }, { 31000, 0 } }
	local scarcity = ore_definition.scarcity
	local num_ores = ore_definition.num_ores
	local size = ore_definition.size
	local clusters = {
		Cluster(scarcity*scarcity*scarcity, num_ores, size),
		Cluster(scarcity*scarcity*scarcity*scarcity, 1.5*num_ores, size+1),
		Cluster(scarcity*scarcity*scarcity*scarcity*scarcity, 0.5*num_ores, size),
	}

	local drop = register_lump(metal, ore_definition.lump)

	local stone_ore = register_ore_node(drop, metal, 2, 'stone')
	register_generations(stone_ore, 'default:stone', clusters, ranges)

	local desert_ore = register_ore_node(drop, metal, 2, 'desert_stone')
	register_generation(desert_ore, 'default:desert_stone', clusters[2], ranges[2])
	register_generation(desert_ore, 'default:desert_stone', clusters[3], ranges[3])
end

for metal, ore_definition in pairs(old_metals) do
	local range = { 31000, 0 }
	local desert_range = { 31000, -256}
	local scarcity = ore_definition.scarcity + 4
	local num_ores = ore_definition.num_ores
	local size = ore_definition.size
	local cluster = Cluster(scarcity*scarcity*scarcity, num_ores, size)

	atualize_ore_node(metal)

	local drop = atualize_lump(metal, ore_definition.lump)
	local desert_ore = register_ore_node(drop, metal, 2, 'desert_stone')
	register_generation(desert_ore, 'default:desert_stone', cluster, desert_range)
	register_generation('default:stone_with_'..metal, 'default:stone', cluster, range)
end

for ore, ore_definition in pairs(ores) do
	local ranges = ore_definition.ranges
	local clusters = ore_definition.clusters

	local drop = MOD_NAME..':'..ore_definition.drop

	local stone_ore = register_ore_node(drop, ore, 2, 'stone')
	register_generations(stone_ore, 'default:stone', clusters, ranges)

	for _, range in ipairs(ranges) do
		if range[1] > -256 then
			local desert_ore = register_ore_node(drop, ore, 2, 'desert_stone')
			register_generation(desert_ore, 'default:desert_stone', clusters[#ranges], ranges[#ranges])
		end
	end
end

for _, gem in ipairs(new_gems) do
	local ranges = {{-1024, -2047}, {-2048, -31000}}
	local scarcities = {17*17*17, 15*15*15}
	local num_ores = 4
	local size = 3
	local clusters = {
		Cluster(scarcities[1], num_ores, size),
		Cluster(scarcities[2], num_ores, size),
	}

	local drop = MOD_NAME..':gems_'..gem
	local stone_ore = register_ore_node(drop, gem, 1, 'stone')
	register_generations(stone_ore, 'default:stone', clusters, ranges)
end

blast_furnace:register_craft('default:iron_lump', 'default:steel_ingot')
