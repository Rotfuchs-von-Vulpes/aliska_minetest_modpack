minetest.register_decoration({
	name = "default:rubber_tree",
	deco_type = "schematic",
	place_on = {"default:dirt_with_grass"},
	sidelen = 16,
	noise_params = {
		offset = 0.0,
		scale = -0.015,
		spread = {x = 250, y = 250, z = 250},
		seed = 2,
		octaves = 3,
		persist = 0.66
	},
	biomes = {"deciduous_forest", 'rainforest_swamp', 'rainforest'},
	y_max = 31000,
	y_min = 1,
	schematic = minetest.get_modpath('aliska_foudation').."/schematics/rubber_tree.mts",
	flags = "place_center_x, place_center_z",
	rotation = "random",
})
