local rocks = {'black_sand', 'black_sandstone', 'basalt', 'limestone', 'mud',
'conglomerate', 'shale', 'schist', 'slate', 'marble', 'quartzite', 'monzonite',
'diorite', 'andesite', 'rhyolite', 'granite', 'gabbro', 'gneiss', 'red_mud'}

local function create_def(description, tile, groups)
	return {
		description = description,
		tile = tile,
		groups = groups
	}
end

local rocks_definition = {
	black_sand = create_def(
		'Basaltic Sand', 'aliska_black_sand.png', {crumbly=3, sand=1}, 'sand'
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

	return MOD_NAME..':'..name
end

for _, rock in ipairs(rocks) do
	local def = rocks_definition[rock]
	register_rock(rock, def.description, def.tile, def.groups)
end
