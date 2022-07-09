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

	local drop = 'aliska_foudation:'..metal..'_lump'

	local stone_ore = 'aliska_foudation:stone_with_'..metal
	register_generations(stone_ore, 'default:stone', clusters, ranges)

	local desert_ore = 'aliska_foudation:desert_stone_with_'..metal
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

	local drop = 'aliska_foudation:'..metal..'_lump'
	local desert_ore = 'aliska_foudation:desert_stone_with_'..metal
	register_generation(desert_ore, 'default:desert_stone', cluster, desert_range)
	register_generation('default:stone_with_'..metal, 'default:stone', cluster, range)
end

for ore, ore_definition in pairs(ores) do
	local ranges = ore_definition.ranges
	local clusters = ore_definition.clusters

	local drop = 'aliska_foudation:'..ore_definition.drop

	local stone_ore = 'aliska_foudation:stone_with_'..ore
	register_generations(stone_ore, 'default:stone', clusters, ranges)

	for _, range in ipairs(ranges) do
		if range[1] > -256 then
			local desert_ore = 'aliska_foudation:desert_stone_with_'..ore
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

	local drop = 'aliska_foudation:gems_'..gem
	local stone_ore = 'aliska_foudation:stone_with_'..gem
	register_generations(stone_ore, 'default:stone', clusters, ranges)
end

register_generation(
	'aliska_foudation:silver_sand_with_niter',
	'default:silver_sand',
	Cluster(12*12*12, 6, 3),
	{31000, -256}
)
