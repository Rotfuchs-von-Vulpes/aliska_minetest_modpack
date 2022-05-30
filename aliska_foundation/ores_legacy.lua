-- iron hematite
-- zinc sphalerite
-- copper chalcopyrite
-- tin cassiterite
-- lead galena

local c = aliska.c

local new_ores = { 'zinc', 'lead', 'titanium', 'nickel', 'aluminium', 'electrum' }
local new_gems = { 'quartz', 'amethyst', 'fluorite', 'ruby', 'emerald', 'sapphire' }
local old_ores = { 'iron', 'copper', 'tin', 'gold' }

local function create_ore_definition(size, count, rarity)
	return {
		rarity = rarity,
		count = count,
		size = size,
	}
end

local function create_generation_definition(ranges, drop, size, count, rarity)

	obj.ranges = ranges

	return obj
end

local function create_metal_ore_definition(lump, size, count, rarity)
	local obj = create_ore_definition(size, count, rarity)

	obj.lump = lump

	return obj
end

local ores = {
	coal = { create_generation_definition({ { -127, 64 } }, 3, 8, 8*8*8) },
	graphite = { create_generation_definition() },
	borax = { create_generation_definition() },
	sulfur = { create_generation_definition() },
	halita = { create_generation_definition() }
}

register_generation(
	MOD_NAME..':desert_stone_with_coal',
	'default:desert_stone',
	{ Cluster(8 * 8 * 8, 8, 3) },
	{ { -127, 64 } }
)
local metal_ores_definition = {
	copper = create_metal_ore_definition('chalcopyrite', 3, 12, 8),
	titanium = create_metal_ore_definition('limenite', 2, 2, 25),
	electrum = create_metal_ore_definition('electrum', 2, 2, 30),
	aluminium = create_metal_ore_definition('bauxite', 2, 2, 8),
	nickel = create_metal_ore_definition('garnierite', 2, 2, 7),
	zinc = create_metal_ore_definition('spharelite', 3, 11, 9),
	tin = create_metal_ore_definition('cassiterite', 3, 12, 8),
	iron = create_metal_ore_definition('hematite', 3, 10, 7),
	lead = create_metal_ore_definition('galena', 2, 2, 9),
	gold = create_metal_ore_definition('gold', 2, 2, 20),
}

local function atualize_old_generation(ore_name1, ore_name2, size, count, rarity)
	minetest.register_ore{
		ore_type = 'scatter',
		ore = ore_name1,
		wherein = 'default:stone',
		clust_scarcity = (rarity + 4) ^ 3,
		clust_num_ores = count,
		clust_size = size,
		y_max = 31000,
		y_min = -64,
	}
	minetest.register_ore{
		ore_type = 'scatter',
		ore = ore_name2,
		wherein = 'default:desert_stone',
		clust_scarcity = (rarity + 4) ^ 3,
		clust_num_ores = count,
		clust_size = size,
		y_max = 31000,
		y_min = -64,
	}
end

local function register_generation(ore_name, wherein, clusters, ranges)
	for i, range in ipairs(ranges) do
		minetest.register_ore{
			ore_type = 'scatter',
			ore = ore_name,
			wherein = wherein,
			clust_scarcity = clusters[i].scarcity,
			clust_num_ores = clusters[i].num_ores,
			clust_size = clusters[i].size,
			y_max = range[2],
			y_min = range[1],
		}
	end
end

local function Cluster(rarity, count, size)
	return { scarcity = rarity, num_ores = count, size = size }
end

local function register_metal_ore(ore_name1, ore_name2, size, count, rarity)
	local ranges = { { -31000, 0 }, { -31000, 64}, { 0, 31000 } }
	local clusters = {
		Cluster(rarity*rarity*rarity, count, size),
		Cluster(rarity*rarity*rarity*rarity, 1.5*count, size+1),
		Cluster(rarity*rarity*rarity*rarity*rarity, 0.5*count, size),
	}

	register_generation(ore_name1, 'default:stone', clusters, ranges)
	register_generation(ore_name2, 'default:desert_stone', clusters, ranges)
end

local function register_gem_ore(ore_name1, ore_name2)
	local ranges = { { -2047, -1024 }, { -31000, -2048} }
	local clusters = {
		Cluster(17 * 17 * 17, 4, 3),
		Cluster(15 * 15 * 15, 4, 3),
	}

	register_generation(ore_name1, ore_name2, clusters, ranges)
end

local function override_ore(metal)
	minetest.override_item('default:'..metal..'_lump', {
		description = c(metal_ores_definition[metal].lump),
		inventory_image = 'aliska_raw_'..metal..'.png',
	})
	minetest.override_item('default:stone_with_'..metal, {
		tiles = { 'default_stone.png^aliska_raw_'..metal..'_ore.png' },
	})
end

local function register_ore(metal, only_desert)
	minetest.register_node(MOD_NAME..':desert_stone_with_'..metal, {
		description = c(metal..'_ore'),
		tiles = { 'default_desert_stone.png^aliska_raw_'..metal..'_ore.png' },
		groups = { cracky=2 },
		drop = MOD_NAME..':'..metal..'_lump',
		sounds = default.node_sound_stone_defaults(),
	})

	if only_desert then return end
	
	minetest.register_craftitem(MOD_NAME..':'..metal..'_lump', {
		description = c(metal_ores_definition[metal].lump),
		inventory_image = 'aliska_raw_'..metal..'.png',
	})

	minetest.register_node(MOD_NAME..':stone_with_'..metal, {
		description = c(metal..'_ore'),
		tiles = { 'default_stone.png^aliska_raw_'..metal..'_ore.png' },
		groups = { cracky=2 },
		drop = MOD_NAME..':'..metal..'_lump',
		sounds = default.node_sound_stone_defaults(),
	})
end

local function register_gem(gem)
	minetest.register_node(MOD_NAME..':stone_with_'..gem, {
		description = c(gem)..' Ore',
		tiles = { 'default_stone.png^aliska_raw_'..gem..'_ore.png' },
		groups = { cracky=1 },
		drop = MOD_NAME..':gems_'..gem,
		sounds = default.node_sound_stone_defaults(),
	})
end

minetest.register_on_mods_loaded(function()
	for _, metal in pairs(old_ores) do
		override_ore(metal)
	end

	minetest.override_item('default:stone_with_diamond', {
		tiles = { 'default_stone.png^aliska_raw_diamond_ore.png' }
	})
	minetest.override_item('default:stone_with_mese', {
		tiles = { 'default_stone.png^aliska_raw_mese_ore.png' }
	})
end)

for _, metal in ipairs(old_ores) do
	local def = metal_ores_definition[metal]

	register_ore(metal, true) -- desert stone only
	atualize_old_generation(
		'default:stone_with_'..metal, MOD_NAME..':desert_stone_with_'..metal, def.size, def.count, def.rarity
	)
	aliska.register_hammer_craft(
		'default:'..metal..'_lump',
		MOD_NAME..':'..metal..'_powder 2'
	)
end

for _, metal in ipairs(new_ores) do
	local powder = MOD_NAME..':'..metal..'_powder'
	local ingot = MOD_NAME..':'..metal..'_ingot'
	local lump = MOD_NAME..':'..metal..'_lump'
	local def = metal_ores_definition[metal]

	register_ore(metal)
	aliska.register_cooking(lump, ingot)
	aliska.register_hammer_craft(lump, powder..' 2')
	register_metal_ore(
		MOD_NAME..':stone_with_'..metal, MOD_NAME..':desert_stone_with_'..metal, def.size, def.count, def.rarity
	)
end

for _, gem in ipairs(new_gems) do
	register_gem(gem)
	register_gem_ore(MOD_NAME..':stone_with_'..gem)
end

minetest.register_node(MOD_NAME..':desert_stone_with_coal', {
	description = 'Coal Ore',
	tiles = { 'default_desert_stone.png^default_mineral_coal.png' },
	groups = { cracky=3 },
	drop = MOD_NAME..':coal_lump',
	sounds = default.node_sound_stone_defaults(),
})
