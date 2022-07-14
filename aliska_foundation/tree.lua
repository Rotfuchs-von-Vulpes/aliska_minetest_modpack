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

minetest.register_node('aliska_foudation:rubber_tree', {
	description = 'Rubber Tree',
	tiles = {'aliska_rubber_tree_top.png', 'aliska_rubber_tree_top.png',
		'aliska_rubber_tree.png'},
	paramtype2 = 'facedir',
	is_ground_content = false,
	groups = {tree = 1, choppy = 3, oddly_breakable_by_hand = 1, flammable = 3},
	sounds = default.node_sound_wood_defaults(),

	on_place = minetest.rotate_node
})
minetest.register_node('aliska_foudation:rubber_tree_with_latex', {
	description = 'Rubber Tree with Latex',
	tiles = {'aliska_rubber_tree_top.png', 'aliska_rubber_tree_top.png',
		'aliska_rubber_tree.png^aliska_latex_filled.png'},
	paramtype2 = 'facedir',
	is_ground_content = false,
	groups = {tree = 1, choppy = 3, oddly_breakable_by_hand = 1, flammable = 3},
	sounds = default.node_sound_wood_defaults(),
	drop = 'aliska_foudation:rubber_tree',
})
minetest.register_node('aliska_foudation:rubber_tree_without_latex', {
	description = 'Rubber Tree without Latex',
	tiles = {'aliska_rubber_tree_top.png', 'aliska_rubber_tree_top.png',
		'aliska_rubber_tree.png^aliska_latex_empty.png'},
	paramtype2 = 'facedir',
	is_ground_content = false,
	groups = {tree = 1, choppy = 3, oddly_breakable_by_hand = 1, flammable = 3},
	sounds = default.node_sound_wood_defaults(),
	drop = 'aliska_foudation:rubber_tree',
})

minetest.register_node('aliska_foudation:rubber_leaves', {
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
			{items = {'aliska_foudation:rubber_leaves'}}
		}
	},
	sounds = default.node_sound_leaves_defaults(),

	after_place_node = default.after_place_leaves,
})

minetest.register_node('aliska_foudation:rubber_sapling', {
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
			'aliska_foudation:rubber_sapling',
			-- minp, maxp to be checked, relative to sapling pos
			-- minp_relative.y = 1 because sapling pos has been checked
			{x = -2, y = 1, z = -2},
			{x = 2, y = 15, z = 2},
			-- maximum interval of interior volume check
			4)

		return itemstack
	end,
})

minetest.register_tool('aliska_foudation:tree_tap', {
	description = 'Tree Tap',
	inventory_image = 'aliska_tree_tap.png',
	on_use = function(itemstack, player, pointed_thing)
		local pos = pointed_thing.under
		if not pos then return end
		local node = minetest.get_node(pos).name
		if node == 'aliska_foudation:rubber_tree_with_latex' then
			minetest.swap_node(pos, {name = 'aliska_foudation:rubber_tree_without_latex'})
			local stack = 'aliska_foudation:latex '..math.random(3)
			local inv = player:get_inventory()

			local idx = player:get_wield_index()
			local list = inv:get_list('main')
			itemstack:add_wear(1200)
			list[idx]:replace(itemstack)
			minetest.after(0, function()
				inv:set_list('main', list)
				
				if inv:room_for_item('main', stack) then
					inv:add_item('main', ItemStack(stack))
				else
					minetest.item_drop(ItemStack(stack), player, player:get_pos())
				end
			end)
		end
	end,
})

minetest.register_craftitem('aliska_foudation:latex', {
	description = 'Latex',
	inventory_image = 'aliska_latex.png'
})
minetest.register_craftitem('aliska_foudation:rubber', {
	description = 'Rubber',
	inventory_image = 'aliska_rubber.png'
})

minetest.register_abm({
	label = 'aliska_foudation:latex_creation',
	nodenames = {'aliska_foudation:rubber_tree_without_latex'},
	neighbors = {'air'},
	interval = 600,
	chance = 1,
	action = function(pos)
		minetest.swap_node(pos, {name='aliska_foudation:rubber_tree_with_latex'})
	end,
})

minetest.register_lbm({
	name = "aliska_foudation:convert_saplings_to_node_timer",
	nodenames = {"aliska_foudation:sapling"},
	action = function(pos)
		minetest.get_node_timer(pos):start(math.random(300, 1500))
	end
})

aliska.register_cooking('aliska_foudation:latex', 'aliska_foudation:rubber')
aliska.register_craft(
	'aliska_foudation:tree_tap',
	{0, 1, 0, 1, 1, 1, 1, 0, 0},
	{'group:wood'}
)
