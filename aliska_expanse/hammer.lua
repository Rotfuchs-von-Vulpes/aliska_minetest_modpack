local metals = {
	'lead', 'iron', 'silver', 'zinc', 'brass',
	'steel', 'copper', 'bronze', 'tin', 'gold', 'aluminium',
	'titanium', 'nickel', 'electrum', 'monel', 'nitinol',
	'invar'
}
registered_metals = {'steel', 'copper', 'bronze', 'tin', 'gold'}

aliska.register_hammer_craft = aliska.register_crafting_tool('forge_hammer', {
	{ 0, 1, 1, 2, 2, 1, 0, 1, 1 },
	{ MOD_NAME..':iron_ingot', 'group:stick' },
})

for _, metal in ipairs(metals) do
	aliska.register_hammer_craft(
		'aliska_foudation:'..metal..'_ingot', 'aliska_foudation:'..metal..'_plate'
	)
end
for _, metal in ipairs(registered_metals) do
	aliska.register_hammer_craft(
		'default:'..metal..'_ingot', 'aliska_foudation:'..metal..'_plate'
	)
end
