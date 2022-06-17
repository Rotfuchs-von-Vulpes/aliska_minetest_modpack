local function grow_sapling(pos)
	if not default.can_grow(pos) then
		-- try again 5 min later
		minetest.get_node_timer(pos):start(300)
		return
	end

	minetest.set_node(pos, {name='air'})
	
	local path = aliska.path..
		"/schematics/rubber_tree.mts"
	minetest.place_schematic({x = pos.x - 2, y = pos.y - 1, z = pos.z - 2},
		path, "random", nil, false)
end

minetest.register_node(MOD_NAME..':rubber_tree', {
	description = 'Rubber Tree',
	tiles = {'aliska_rubber_tree_top.png', 'aliska_rubber_tree_top.png',
		'aliska_rubber_tree.png'},
	paramtype2 = 'facedir',
	is_ground_content = false,
	groups = {tree = 1, choppy = 3, oddly_breakable_by_hand = 1, flammable = 3},
	sounds = default.node_sound_wood_defaults(),

	on_place = minetest.rotate_node
})
minetest.register_node(MOD_NAME..':rubber_tree_with_latex', {
	description = 'Rubber Tree with Latex',
	tiles = {'aliska_rubber_tree_top.png', 'aliska_rubber_tree_top.png',
		'aliska_rubber_tree.png^aliska_latex_filled.png'},
	paramtype2 = 'facedir',
	is_ground_content = false,
	groups = {tree = 1, choppy = 3, oddly_breakable_by_hand = 1, flammable = 3},
	sounds = default.node_sound_wood_defaults(),
	drop = MOD_NAME..':rubber_tree',
})
minetest.register_node(MOD_NAME..':rubber_tree_without_latex', {
	description = 'Rubber Tree without Latex',
	tiles = {'aliska_rubber_tree_top.png', 'aliska_rubber_tree_top.png',
		'aliska_rubber_tree.png^aliska_latex_empty.png'},
	paramtype2 = 'facedir',
	is_ground_content = false,
	groups = {tree = 1, choppy = 3, oddly_breakable_by_hand = 1, flammable = 3},
	sounds = default.node_sound_wood_defaults(),
	drop = MOD_NAME..':rubber_tree',
})

minetest.register_node(MOD_NAME..':rubber_wood', {
	description = 'Rubber Wood Planks',
	paramtype2 = 'facedir',
	place_param2 = 0,
	tiles = {'aliska_rubber_wood.png'},
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node(MOD_NAME..':rubber_leaves', {
	description = 'Rubber Tree Leaves',
	drawtype = 'allfaces_optional',
	waving = 1,
	tiles = {'aliska_rubber_leaves.png'},
	special_tiles = {'default_jungleleaves_simple.png'},
	paramtype = 'light',
	is_ground_content = false,
	groups = {snappy = 3, leafdecay = 3, flammable = 2, leaves = 1},
	drop = {
		max_items = 1,
		items = {
			-- {items = {'default:junglesapling'}, rarity = 20},
			{items = {MOD_NAME..':rubber_leaves'}}
		}
	},
	sounds = default.node_sound_leaves_defaults(),

	after_place_node = default.after_place_leaves,
})

minetest.register_node(MOD_NAME..':rubber_sapling', {
	description = 'Rubber Tree Sapling',
	drawtype = 'plantlike',
	tiles = {'aliska_rubber_sapling.png'},
	inventory_image = 'aliska_rubber_sapling.png',
	wield_image = 'aliska_rubber_sapling.png',
	paramtype = 'light',
	sunlight_propagates = true,
	walkable = false,
	on_timer = grow_sapling,
	selection_box = {
		type = 'fixed',
		fixed = {-4 / 16, -0.5, -4 / 16, 4 / 16, 7 / 16, 4 / 16}
	},
	groups = {snappy = 2, dig_immediate = 3, flammable = 2,
		attached_node = 1, sapling = 1},
	sounds = default.node_sound_leaves_defaults(),

	on_construct = function(pos)
		minetest.get_node_timer(pos):start(math.random(300, 1500))
	end,

	on_place = function(itemstack, placer, pointed_thing)
		itemstack = default.sapling_on_place(itemstack, placer, pointed_thing,
			MOD_NAME..':rubber_sapling',
			-- minp, maxp to be checked, relative to sapling pos
			-- minp_relative.y = 1 because sapling pos has been checked
			{x = -2, y = 1, z = -2},
			{x = 2, y = 15, z = 2},
			-- maximum interval of interior volume check
			4)

		return itemstack
	end,
})

minetest.register_tool(MOD_NAME..':tree_tap', {
	description = 'Tree Tap',
	inventory_image = 'aliska_tree_tap.png',
	on_use = function(itemstack, player, pointed_thing)
		local pos = pointed_thing.under
		if not pos then return end
		local node = minetest.get_node(pos).name
		if node == MOD_NAME..':rubber_tree_with_latex' then
			minetest.swap_node(pos, {name = MOD_NAME..':rubber_tree_without_latex'})
			local stack = MOD_NAME..':latex '..math.random(3)
			local inv = player:get_inventory()

			local idx = player:get_wield_index()
			local list = inv:get_list('main')
			itemstack:add_wear(1200)
			list[idx]:replace(itemstack)
			minetest.after(0, function()
				inv:set_list('main', list)
			end)

			if inv:room_for_item('main', stack) then
				inv:add_item('main', stack)
			else
				minetest.item_drop(ItemStack(stack), player, player:get_pos())
			end
		end
	end,
})

minetest.register_craftitem(MOD_NAME..':latex', {
	description = 'Latex',
	inventory_image = 'aliska_latex.png'
})
minetest.register_craftitem(MOD_NAME..':rubber', {
	description = 'Rubber',
	inventory_image = 'aliska_rubber.png'
})

minetest.register_abm({
	label = MOD_NAME..':latex_creation',
	nodenames = {MOD_NAME..':rubber_tree_without_latex'},
	neighbors = {'air'},
	interval = 600,
	chance = 1,
	action = function(pos)
		minetest.swap_node(pos, {name=MOD_NAME..':rubber_tree_with_latex'})
	end,
})

minetest.register_lbm({
	name = MOD_NAME..":convert_saplings_to_node_timer",
	nodenames = {MOD_NAME..":sapling"},
	action = function(pos)
		minetest.get_node_timer(pos):start(math.random(300, 1500))
	end
})

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
	schematic = aliska.path.."/schematics/rubber_tree.mts",
	flags = "place_center_x, place_center_z",
	rotation = "random",
})

aliska.register_cooking(MOD_NAME..':latex', MOD_NAME..':rubber')
aliska.register_craft(MOD_NAME..':rubber_wood 4', {1}, {MOD_NAME..':rubber_tree'})
aliska.register_craft(
	MOD_NAME..':tree_tap',
	{0, 1, 0, 1, 1, 1, 1, 0, 0},
	{'group:wood'}
)
