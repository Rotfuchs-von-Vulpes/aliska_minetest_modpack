local oceand = {'icesheet_ocean', 'tundra_ocean', 'taiga_ocean',
'snowy_grassland_ocean', 'grassland_ocean', 'coniferous_forest_ocean',
'deciduous_forest_ocean', 'desert_ocean', 'sandstone_desert_ocean',
'cold_desert_ocean', 'savanna_ocean', 'rainforest_ocean'}

local blob_generated = {'limestone', 'conglomerate', 'schist', 'slate', 'gneiss',
'marble', 'monzonite', 'diorite', 'andesite', 'rhyolite', 'granite', 'gabbro'}
local blob_biomes = {
	shale = {'rainforest_swamp'},
	basalt = oceans,
	black_sand = oceans,
	quartzite = {'cold_desert', 'sandstone_desert', 'desert'}
}

local function create_def(description, tile, groups)
	return {
		description = description,
		tile = tile,
		groups = groups
	}
end

local rocks_definition = {
	black_sand = create_def(
		'Basaltic Sand', 'aliska_black_sand.png', {crumbly=3}, 'sand'
	),
	black_sandstone = create_def(
		'Basaltic Sandstone', 'aliska_black_sandstone.png',
		{crumbly=1, cracky=3}, 'stone'
	),
	basalt = create_def(
		'Basalt', 'aliska_basalt.png',  {cracky=3, stone=1}, 'stone'
	),
	limestone = create_def(
		'Limestone', 'aliska_limestone.png', {cracky=3}, 'stone'
	),
	mud = create_def(
		'Mud', 'aliska_mud.png', {crumbly=3, soil=1}, 'dirt'
	),
	red_mud = create_def(
		'Red Mud', 'aliska_red_mud.png', {crumbly=3, soil=1}, 'dirt'
	),
	conglomerate = create_def(
		'Conglomerate', 'aliska_conglomerate.png', {crumbly=1, cracky=3}, 'stone'
	),
	shale = create_def(
		'Shale', 'aliska_shale.png', {crumbly=1, cracky=3}, 'stone'
	),
	schist = create_def(
		'Schist', 'aliska_schist.png', {cracky=3}, 'stone'
	),
	slate = create_def(
		'Slate', 'aliska_slate.png', {cracky=3, stone=1}, 'stone'
	),
	marble = create_def(
		'Marble', 'aliska_marble.png', {cracky=3, stone=1}, 'stone'
	),
	quartzite = create_def(
		'quartzite', 'aliska_quartzite.png', {crumbly=1, cracky=3}, 'stone'
	),
	monzonite = create_def(
		'Monzonite', 'aliska_monzonite.png', {cracky=3, stone=1}, 'stone'
	),
	diorite = create_def(
		'Diorite', 'aliska_diorite.png', {cracky=3, stone=1}, 'stone'
	),
	andesite = create_def(
		'Andesite', 'aliska_andesite.png', {cracky=3, stone=1}, 'stone'
	),
	rhyolite = create_def(
		'Rhyolite', 'aliska_rhyolite.png', {cracky=3, stone=1}, 'stone'
	),
	granite = create_def(
		'Granite', 'aliska_granite.png', {cracky=3, stone=1}, 'stone'
	),
	gabbro = create_def(
		'Gabbro', 'aliska_gabbro.png', {cracky=3, stone=1}, 'stone'
	),
	gneiss = create_def(
		'Gneiss', 'aliska_gneiss.png', {cracky=3, stone=1}, 'stone'
	),
}

local function register_rock(name, description, tile, groups, sounds)
	if sounds == 'stone' then 
		sounds = default.node_sound_stone_defaults()
	elseif sounds == 'sand' then 
		sounds = default.node_sound_sand_defaults()
	elseif sounds == 'dirt' then
		sounds = default.node_sound_dirt_defaults()
	end

	minetest.register_node(MOD_NAME..':rocks_'..name, {
		description = description,
		tiles = { tile },
		groups = groups,
		sounds = sounds,
	})

	return MOD_NAME..':rocks_'..name
end

local function register_blob(rock, biomes, wherein)
	wherein = wherein or {'default:stone'}
	
	local def = {
		ore_type = "blob",
		ore = rock,
		wherein  = wherein,
		clust_scarcity = 18 * 18 * 18,
		clust_size = 5,
		y_max = 31000,
		y_min = -31000,
		noise_threshold = 0.0,
		noise_params = {
			offset = 0.5,
			scale = 0.2,
			spread = {x = 5, y = 5, z = 5},
			seed = 766,
			octaves = 1,
			persist = 0.0
		}
	}

	if biomes then def.biomes = biomes end
	
	minetest.register_ore(def)
end

minetest.register_ore{
	ore_type = "vein",
	ore = MOD_NAME..':rocks_basalt',
	wherein  = {'default:stone'},
	y_max = -256,
	y_min = -31000,
	noise_params = {
		octaves = 4,
		seed = 25391,
		spread = {
			y = 200,
			x = 200,
			z = 200
		},
		persist = 0.5,
		flags = "eased",
		offset = 0,
		scale = 3
	},
	noise_threshold = 0.9,
	random_factor = 0,
}

for rock, def in pairs(rocks_definition) do
	rock = register_rock(rock, def.description, def.tile, def.groups)
end

for _, rock in ipairs(blob_generated) do 
	register_blob(MOD_NAME..':rocks_'..rock)
end

for rock, biomes in pairs(blob_biomes) do
	register_blob(
		MOD_NAME..':rocks_'..rock,
		biomes,
		{'default:stone', 'default:desert_stone'
	})
end
