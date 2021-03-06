aliska = {}
MOD_NAME = minetest.get_current_modname()

aliska.path = minetest.get_modpath(MOD_NAME)

dofile(aliska.path..'/utils.lua')

local metals = {
	'lead', 'iron', 'silver', 'zinc', 'brass',
	'steel', 'copper', 'bronze', 'tin', 'gold', 'aluminium',
	'titanium', 'nickel', 'electrum', 'monel', 'nitinol',
	'invar'
}
registered_metals = {'steel', 'copper', 'bronze', 'tin', 'gold'}
registered_metals_set = aliska.Set(registered_metals)

dofile(aliska.path..'/resources.lua')
dofile(aliska.path..'/liquids.lua')
dofile(aliska.path..'/metal.lua')
dofile(aliska.path..'/gems.lua')
dofile(aliska.path..'/tools.lua')

dofile(aliska.path..'/rocks.lua')
dofile(aliska.path..'/ores.lua')
dofile(aliska.path..'/tree.lua')

for _, metal in ipairs(metals) do
	local items = aliska.register_metal(metal)

	aliska.register_tools(metal, items)
end
