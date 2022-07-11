local c = aliska.c

minetest.register_on_mods_loaded(function()
	minetest.override_item('default:coal_lump', {
		description = 'Coal',
		inventory_image = 'aliska_coal.png'
	})
end)

minetest.register_craftitem('aliska_foudation:coke', {
	description = 'Coal Coke',
	inventory_image = 'aliska_coke.png'
})
minetest.register_craftitem('aliska_foudation:charcoal', {
	description = 'Charcoal',
	inventory_image = 'aliska_charcoal.png'
})
minetest.register_craftitem('aliska_foudation:coal_powder', {
	description = 'Coal Powder',
	inventory_image = 'aliska_coal_powder.png'
})
minetest.register_craftitem('aliska_foudation:sulfur', {
	description = 'Sulfur',
	inventory_image = 'aliska_sulfur.png'
})
minetest.register_craftitem('aliska_foudation:silica_powder', {
	description = 'Silica Powder',
	inventory_image = 'aliska_silica_powder.png'
})
minetest.register_craftitem('aliska_foudation:silica', {
	description = 'Silica',
	inventory_image = 'aliska_silica.png'
})
minetest.register_craftitem('aliska_foudation:graphite', {
	description = 'Graphite',
	inventory_image = 'aliska_graphite.png'
})

minetest.register_node('aliska_foudation:graphite_block', {
	description = 'Graphite Block',
	tiles = { 'aliska_graphite_block.png' },
	drop = 'aliska_foudation:graphite_block',
	groups = {cracky = 3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})
minetest.register_node('aliska_foudation:charcoal_block', {
	description = 'Charcoal Block',
	tiles = { 'aliska_charcoal_block.png' },
	drop = 'aliska_foudation:charcoal_block',
	groups = {cracky = 3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})
minetest.register_node("aliska_foudation:treated_wood", {
	description = "Treated Wood Planks",
	paramtype2 = "facedir",
	place_param2 = 0,
	tiles = {"aliska_treated_wood.png"},
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2},
	sounds = default.node_sound_wood_defaults(),
})

if minetest.get_modpath('stairs') then
	aliska.register_stair_and_slab(
		"treated_wood",
		"aliska_foudation:treated_wood",
		{choppy = 3, oddly_breakable_by_hand = 2, flammable = 3},
		{"aliska_treated_wood.png"},
		"Treated Wood Stair",
		"Treated Wood Slab",
		default.node_sound_wood_defaults(),
		false
	)
end


minetest.register_craft{
	type = 'fuel',
	recipe = 'aliska_foudation:coke',
	burntime = 160,
}
minetest.register_craft{
	type = 'fuel',
	recipe = 'aliska_foudation:charcoal',
	burntime = 40,
}
minetest.register_craft{
	type = 'fuel',
	recipe = 'group:tree',
	burntime = 3,
}
minetest.register_craft{
	type = 'shapeless',
	recipe = {'group:wood', 'aliska_foudation:glass_bottle_creosote_oil'},
	output = 'aliska_foudation:treated_wood',
	replacements = {{'aliska_foudation:glass_bottle_creosote_oil', 'vessels:glass_bottle'}}
}

for _, powder in ipairs({
	'salt', 'niter', 'sugar', 'alumina', 'calcium_carbonate', 'sodium_hidroxide'
}) do
	minetest.register_craftitem('aliska_foudation:'..powder, {
		description = c(powder),
		inventory_image = 'aliska_salt.png'
	})
	minetest.register_node('aliska_foudation:'..powder..'_block', {
		description = c(powder)..' Block',
		tiles = { 'aliska_salt_block.png' },
		groups = {cracky = 3},
		sounds = default.node_sound_stone_defaults(),
	})
	aliska.register_craft(
		'aliska_foudation:'..powder..'_block',
		{1, 1, 1, 1, 1, 1, 1, 1, 1},
		{ 'aliska_foudation:'..powder }
	)
	aliska.register_craft(
		'aliska_foudation:'..powder..' 9',
		{1},
		{ 'aliska_foudation:'..powder..'_block' }
	)
end

minetest.override_item('aliska_foudation:niter', {
	on_use = function(itemstack, player, pointed_thing)
		local pos = pointed_thing.under
		if not pos then return end
		local node = minetest.get_node(pos).name
		if minetest.registered_nodes[node].groups.sapling then
			minetest.get_node_timer(pos):start(0)
		end
	end,
})

minetest.register_node('aliska_foudation:coke_block', {
	description = 'Coal Coke Block',
	tiles = { 'aliska_coke_block.png' },
	drop = 'aliska_foudation:coke_block',
	groups = {cracky = 3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

aliska.register_cooking('group:tree', 'aliska_foudation:charcoal')
aliska.register_cooking('aliska_foudation:silica_powder', 'aliska_foudation:silica')
aliska.register_cooking('aliska_foudation:silica', 'aliska_foudation:gems_quartz')
aliska.register_craft(
	'aliska_foudation:coke_furnace_bricks 3',
	{1, 2, 1, 2, 1, 2, 1, 2, 1},
	{'group:sand', 'default:clay_brick'}
)
aliska.register_craft(
	'aliska_foudation:coke_block',
	{1, 1, 1, 1, 1, 1, 1, 1, 1},
	{ 'aliska_foudation:coke' }
)
aliska.register_craft(
	'aliska_foudation:coke 9',
	{1},
	{ 'aliska_foudation:coke_block' }
)
aliska.register_craft(
	'default:torch 4',
	{ 1, 0, 2, 0 },
	{ 'aliska_foudation:charcoal', 'group:stick' }
)
aliska.register_craft(
	'tnt:gunpowder 4',
	{ 1, 2, 2, 3 },
	{ 'aliska_foudation:coal_powder', 'aliska_foudation:niter', 'aliska_foudation:sulfur' }
)
aliska.register_craft(
	'aliska_foudation:graphite_block',
	{1, 1, 1, 1, 1, 1, 1, 1, 1},
	{ 'aliska_foudation:graphite' }
)
aliska.register_craft(
	'aliska_foudation:graphite 9',
	{1},
	{ 'aliska_foudation:graphite_block' }
)
aliska.register_craft(
	'aliska_foudation:charcoal_block',
	{1, 1, 1, 1, 1, 1, 1, 1, 1},
	{ 'aliska_foudation:charcoal' }
)
aliska.register_craft(
	'aliska_foudation:charcoal 9',
	{1},
	{ 'aliska_foudation:charcoal_block' }
)
