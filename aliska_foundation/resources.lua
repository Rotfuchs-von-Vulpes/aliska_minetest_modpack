local c = aliska.c

minetest.register_on_mods_loaded(function()
	minetest.override_item('default:coal_lump', {
		description = 'Coal',
		inventory_image = 'aliska_coal.png'
	})
end)

minetest.register_craftitem(MOD_NAME..':charcoal', {
	description = 'Charcoal',
	inventory_image = 'aliska_charcoal.png'
})
minetest.register_craftitem(MOD_NAME..':coke', {
	description = 'Coal Coke',
	inventory_image = 'aliska_coke.png'
})
minetest.register_craftitem(MOD_NAME..':coal_powder', {
	description = 'Coal Powder',
	inventory_image = 'aliska_coal_powder.png'
})
minetest.register_craftitem(MOD_NAME..':sulfur', {
	description = 'Sulfur',
	inventory_image = 'aliska_sulfur.png'
})
minetest.register_craftitem(MOD_NAME..':latex', {
	description = 'Latex',
	inventory_image = 'aliska_latex.png'
})
minetest.register_craftitem(MOD_NAME..':rubber', {
	description = 'Rubber',
	inventory_image = 'aliska_rubber.png'
})
minetest.register_craftitem(MOD_NAME..':silica', {
	description = 'Silica',
	inventory_image = 'aliska_silica.png'
})
minetest.register_craftitem(MOD_NAME..':graphite', {
	description = 'Graphite',
	inventory_image = 'aliska_graphite.png'
})

minetest.register_node(MOD_NAME..':graphite_block', {
	description = 'Graphite Block',
	tiles = { 'aliska_graphite_block.png' },
	groups = {cracky = 3},
	sounds = default.node_sound_stone_defaults(),
})
minetest.register_node(MOD_NAME..':coke_block', {
	description = 'Coal Coke Block',
	tiles = { 'aliska_coke_block.png' },
	groups = {cracky = 3},
	sounds = default.node_sound_stone_defaults(),
})
minetest.register_node(MOD_NAME..':charcoal_block', {
	description = 'Charcoal Block',
	tiles = { 'aliska_charcoal_block.png' },
	groups = {cracky = 3},
	sounds = default.node_sound_stone_defaults(),
})
minetest.register_node(MOD_NAME..':blast_furnace_bricks', {
	description = 'Blast Furnace Bricks',
	tiles = { 'aliska_blast_furnace_bricks.png' },
	groups = {cracky = 3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft{
	type = 'fuel',
	recipe = MOD_NAME..':charcoal',
	burntime = 40,
}
minetest.register_craft{
	type = 'fuel',
	recipe = 'group:tree',
	burntime = 1,
}

for _, powder in ipairs({
	'salt', 'niter', 'sugar', 'alumina', 'calcium_carbonate', 'sodium_hidroxide'
}) do
	minetest.register_craftitem(MOD_NAME..':'..powder, {
		description = c(powder),
		inventory_image = 'aliska_salt.png'
	})
	minetest.register_node(MOD_NAME..':'..powder..'_block', {
		description = c(powder)..' Block',
		tiles = { 'aliska_salt_block.png' },
		groups = {cracky = 3},
		sounds = default.node_sound_stone_defaults(),
	})
	aliska.register_craft(
		MOD_NAME..':'..powder..'_block',
		{1, 1, 1, 1, 1, 1, 1, 1, 1},
		{ MOD_NAME..':'..powder }
	)
	aliska.register_craft(
		MOD_NAME..':'..powder..' 9',
		{1},
		{ MOD_NAME..':'..powder..'_block' }
	)
end

aliska.register_cooking('group:tree', MOD_NAME..':charcoal')
aliska.register_cooking(MOD_NAME..':silica', MOD_NAME..':gems_quartz')
aliska.register_craft(
	'default:torch 4',
	{ 1, 0, 2, 0 },
	{ MOD_NAME..':charcoal', 'group:stick' }
)
aliska.register_craft(
	'tnt:gunpowder 4',
	{ 1, 2, 2, 3 },
	{ MOD_NAME..':coal_powder', MOD_NAME..':niter', MOD_NAME..':sulfur' }
)
aliska.register_craft(
	MOD_NAME..':graphite_block',
	{1, 1, 1, 1, 1, 1, 1, 1, 1},
	{ MOD_NAME..':graphite' }
)
aliska.register_craft(
	MOD_NAME..':graphite 9',
	{1},
	{ MOD_NAME..':graphite_block' }
)
aliska.register_grinder_craft('default:coal_lump', MOD_NAME..':coal_powder')
aliska.register_grinder_craft('default:silver_sand', MOD_NAME..':silica 9')
aliska.register_grinder_craft(MOD_NAME..':gems_quartz', MOD_NAME..':silica')