MOD_NAME = 'aliska_expanse'
FOUDATION = 'aliska_foudation'

aliska.path = minetest.get_modpath('aliska_expanse')

dofile(aliska.path..'/crafting_items.lua')
dofile(aliska.path..'/machines.lua')
dofile(aliska.path..'/multinode.lua')

dofile(aliska.path..'/hammer.lua')
dofile(aliska.path..'/grinder.lua')
dofile(aliska.path..'/dynamo.lua')
dofile(aliska.path..'/coke_oven.lua')
dofile(aliska.path..'/blast_furnace.lua')