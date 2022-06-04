local function register_liquid(name, description, tile, viscosity, length, color)
	minetest.register_node(name..'_source', {
		description = description.." Source",
		drawtype = "liquid",
		waving = 3,
		tiles = {
			{
				name = tile..'_source_animated.png',
				backface_culling = false,
				animation = {
					type = "vertical_frames",
					aspect_w = 16,
					aspect_h = 16,
					length = 4*length,
				},
			},
			{
				name = tile..'_source_animated.png',
				backface_culling = true,
				animation = {
					type = "vertical_frames",
					aspect_w = 16,
					aspect_h = 16,
					length = 4*length,
				},
			},
		},
		use_texture_alpha = "blend",
		paramtype = "light",
		walkable = false,
		pointable = false,
		diggable = false,
		buildable_to = true,
		is_ground_content = false,
		drop = "",
		drowning = 1,
		liquidtype = "source",
		liquid_alternative_flowing = name..'_flowing',
		liquid_alternative_source = name..'_source',
		liquid_viscosity = viscosity,
		post_effect_color = {a = color[4], r = color[1], g = color[2], b = color[3]},
		groups = {liquid = 3, cools_lava = 1},
		sounds = default.node_sound_water_defaults(),
	})
	minetest.register_node(name.."_flowing", {
		description = "Flowing "..description,
		drawtype = "flowingliquid",
		waving = 3,
		tiles = {tile..".png"},
		special_tiles = {
			{
				name = tile.."_flowing_animated.png",
				backface_culling = false,
				animation = {
					type = "vertical_frames",
					aspect_w = 16,
					aspect_h = 16,
					length = length,
				},
			},
			{
				name = tile.."_flowing_animated.png",
				backface_culling = true,
				animation = {
					type = "vertical_frames",
					aspect_w = 16,
					aspect_h = 16,
					length = length,
				},
			},
		},
		use_texture_alpha = "blend",
		paramtype = "light",
		paramtype2 = "flowingliquid",
		walkable = false,
		pointable = false,
		diggable = false,
		buildable_to = true,
		is_ground_content = false,
		drop = "",
		drowning = 1,
		liquidtype = "flowing",
		liquid_alternative_flowing = name..'_flowing',
		liquid_alternative_source = name..'_source',
		liquid_viscosity = 3,
		post_effect_color = {a = color[4], r = color[1], g = color[2], b = color[3]},
		groups = {liquid = 3, not_in_creative_inventory = 1, cools_lava = 1},
		sounds = default.node_sound_water_defaults(),
	})
end

register_liquid(
	MOD_NAME..':oil',
	'Oil',
	'aliska_oil',
	3, 1, {36, 31, 31, 191}
)
register_liquid(
	MOD_NAME..':creosote_oil',
	'Creosote Oil',
	'aliska_creosote_oil',
	1, 0.5, {138, 111, 48, 191}
)