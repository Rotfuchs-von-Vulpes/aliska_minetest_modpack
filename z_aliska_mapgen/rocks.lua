local oceans = {'icesheet_ocean', 'tundra_ocean', 'taiga_ocean',
'snowy_grassland_ocean', 'grassland_ocean', 'coniferous_forest_ocean',
'deciduous_forest_ocean', 'desert_ocean', 'sandstone_desert_ocean',
'cold_desert_ocean', 'savanna_ocean', 'rainforest_ocean'}

local blob_generated = {'limestone', 'conglomerate', 'schist', 'slate', 'gneiss',
'marble', 'monzonite', 'diorite', 'andesite', 'rhyolite', 'granite', 'gabbro'}
local blob_biomes = {
	shale = {'rainforest_swamp'},
	basalt = oceans,
	black_sand = oceans,
	quartzite = {'cold_desert', 'sandstone_desert', 'desert',
	'desert_ocean', 'sandstone_desert_ocean', 'cold_desert_ocean'}
}

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
	ore = 'aliska_foudation:rocks_basalt',
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

for _, rock in ipairs(blob_generated) do 
	register_blob('aliska_foudation:rocks_'..rock)
end

for rock, biomes in pairs(blob_biomes) do
	register_blob(
		'aliska_foudation:rocks_'..rock,
		biomes,
		{
			'default:stone', 'default:desert_stone',
			'default:sandstone', 'default:desert_sandstone', 'default:silver_sandstone',
		}
	)
end
