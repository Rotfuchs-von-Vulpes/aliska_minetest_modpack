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

minetest.register_node(MOD_NAME..':rubber_wood', {
	description = 'Rubber Wood Planks',
	paramtype2 = 'facedir',
	place_param2 = 0,
	tiles = {'aliska_rubber_wood.png'},
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node(MOD_NAME..":rubber_leaves", {
	description = "Rubber Tree Leaves",
	drawtype = "allfaces_optional",
	waving = 1,
	tiles = {"aliska_rubber_leaves.png"},
	special_tiles = {"default_jungleleaves_simple.png"},
	paramtype = "light",
	is_ground_content = false,
	groups = {snappy = 3, leafdecay = 3, flammable = 2, leaves = 1},
	drop = {
		max_items = 1,
		items = {
			-- {items = {"default:junglesapling"}, rarity = 20},
			{items = {MOD_NAME..":rubber_leaves"}}
		}
	},
	sounds = default.node_sound_leaves_defaults(),

	after_place_node = default.after_place_leaves,
})

aliska.register_craft(MOD_NAME..':rubber_wood 4', {1}, {MOD_NAME..':rubber_tree'})
