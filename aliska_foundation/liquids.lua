local function register_liquid(
	name, description, tile, viscosity, length, color, groups,
	bucket_name, bucket_tile, bucket_description, bucket_groups
)
	local source = name..'_source'
	local flowing = name..'flowing'
	minetest.register_node(source, {
		description = description..' Source',
		drawtype = 'liquid',
		waving = 3,
		tiles = {
			{
				name = tile..'_source_animated.png',
				backface_culling = false,
				animation = {
					type = 'vertical_frames',
					aspect_w = 16,
					aspect_h = 16,
					length = 4*length,
				},
			},
			{
				name = tile..'_source_animated.png',
				backface_culling = true,
				animation = {
					type = 'vertical_frames',
					aspect_w = 16,
					aspect_h = 16,
					length = 4*length,
				},
			},
		},
		use_texture_alpha = 'blend',
		paramtype = 'light',
		walkable = false,
		pointable = false,
		diggable = false,
		buildable_to = true,
		is_ground_content = false,
		drop = '',
		drowning = 1,
		liquidtype = 'source',
		liquid_alternative_flowing = flowing,
		liquid_alternative_source = source,
		liquid_viscosity = viscosity,
		liquid_renewable = false,
		post_effect_color = {a = color[4], r = color[1], g = color[2], b = color[3]},
		groups = {liquid = 3, cools_lava = 1},
		sounds = default.node_sound_water_defaults(),
	})
	minetest.register_node(flowing, {
		description = 'Flowing '..description,
		drawtype = 'flowingliquid',
		waving = 3,
		tiles = {tile..'.png'},
		special_tiles = {
			{
				name = tile..'_flowing_animated.png',
				backface_culling = false,
				animation = {
					type = 'vertical_frames',
					aspect_w = 16,
					aspect_h = 16,
					length = length,
				},
			},
			{
				name = tile..'_flowing_animated.png',
				backface_culling = true,
				animation = {
					type = 'vertical_frames',
					aspect_w = 16,
					aspect_h = 16,
					length = length,
				},
			},
		},
		use_texture_alpha = 'blend',
		paramtype = 'light',
		paramtype2 = 'flowingliquid',
		walkable = false,
		pointable = false,
		diggable = false,
		buildable_to = true,
		is_ground_content = false,
		drop = '',
		drowning = 1,
		liquidtype = 'flowing',
		liquid_alternative_flowing = flowing,
		liquid_alternative_source = source,
		liquid_viscosity = viscosity,
		liquid_renewable = false,
		post_effect_color = {a = color[4], r = color[1], g = color[2], b = color[3]},
		groups = groups,
		sounds = default.node_sound_water_defaults(),
	})

	bucket.register_liquid(
		source,
		flowing,
		bucket_name,
		bucket_tile,
		bucket_description,
		bucket_groups
	)
end

local function register_bottle(name, description, tile)
	minetest.register_node(name, {
		description = description,
		drawtype = 'plantlike',
		tiles = {tile},
		inventory_image = tile,
		wield_image = tile,
		paramtype = 'light',
		is_ground_content = false,
		walkable = false,
		selection_box = {
			type = 'fixed',
			fixed = {-0.25, -0.5, -0.25, 0.25, 0.3, 0.25}
		},
		groups = {vessel = 1, dig_immediate = 3, attached_node = 1},
		sounds = default.node_sound_glass_defaults(),
	})
end

minetest.register_on_mods_loaded(function()
	minetest.override_item('bucket:bucket_empty', {
		inventory_image = 'aliska_bucket_empty.png'
	})
	minetest.override_item('bucket:bucket_lava', {
		inventory_image = 'aliska_bucket_lava.png'
	})
	minetest.override_item('bucket:bucket_water', {
		inventory_image = 'aliska_bucket_water.png'
	})
	minetest.override_item('bucket:bucket_river_water', {
		inventory_image = 'aliska_bucket_river_water.png'
	})
end)

register_liquid(
	'aliska_foudation:oil',
	'Oil',
	'aliska_oil',
	3, 1, {36, 31, 31, 191},
	{liquid = 3, not_in_creative_inventory = 1, cools_lava = 1, fuel = 1},
	'aliska_foudation:bucket_oil',
	'aliska_bucket_oil.png',
	'Oil Bucket',
	{tool = 1}
)
register_liquid(
	'aliska_foudation:creosote_oil',
	'Creosote Oil',
	'aliska_creosote_oil',
	1, 0.5, {138, 111, 48, 191},
	{liquid = 3, not_in_creative_inventory = 1, cools_lava = 1},
	'aliska_foudation:bucket_creosote_oil',
	'aliska_bucket_creosote_oil.png',
	'Creosote Oil Bucket',
	{tool = 1}
)

register_bottle(
	'aliska_foudation:glass_bottle_creosote_oil',
	'Creosote Oil Glass Bottle',
	'aliska_glass_bottle_creosote_oil.png'
)

minetest.register_craft({
	type = 'fuel',
	recipe = 'aliska_foudation:bucket_oil',
	burntime = 60,
	replacements = {{'aliska_foudation:bucket_oil', 'bucket:bucket_empty'}},
})
