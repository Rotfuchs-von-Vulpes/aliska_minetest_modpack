aliska = {}
MOD_NAME = 'aliska_foudation'

aliska.path = minetest.get_modpath(MOD_NAME)

dofile(aliska.path..'/utils.lua')

local metals = {
	'lead', 'iron', 'cast_iron', 'silver', 'zinc', 'brass',
	'steel', 'copper', 'bronze', 'tin', 'gold', 'aluminium',
	'titanium', 'nickel', 'electrum', 'monel', 'nitinol',
	'invar'
}
registered_metals = {'steel', 'copper', 'bronze', 'tin', 'gold'}
registered_metals_set = aliska.Set(registered_metals)

dofile(aliska.path..'/crafting_items.lua')
dofile(aliska.path..'/grinder.lua')

dofile(aliska.path..'/multinode.lua')
dofile(aliska.path..'/coke_oven.lua')

dofile(aliska.path..'/resources.lua')
dofile(aliska.path..'/metal.lua')
dofile(aliska.path..'/gems.lua')
dofile(aliska.path..'/tools.lua')

dofile(aliska.path..'/ores.lua')

for _, metal in ipairs(metals) do
	local items = aliska.register_metal(metal)

	aliska.register_tools(metal, items)
end

minetest.register_chatcommand('that', {
	func = function(name)
		local player = minetest.get_player_by_name(name)
		
		minetest.chat_send_all(
			aliska.serialize(
				minetest.registered_tools[player:get_wielded_item():get_name()]
			)
		)
	end
})
