local c = aliska.c

local new_gems = {
	'emerald', 'sapphire', 'ruby', 'quartz', 'fluorite', 'amethyst', 'borax'
}
local old_gems = {'diamond'}

local function register_gem(gem_name)
	minetest.register_craftitem(MOD_NAME..':gems_'..gem_name, {
		description = c(gem_name),
		inventory_image = 'aliska_gems_'..gem_name..'.png',
	})
	minetest.register_node(MOD_NAME..':gems_'..gem_name..'_block', {
		description = c(gem_name)..' Block',
		tiles = { 'aliska_gems_'..gem_name..'_block.png' },
		is_ground_content = false,
		groups = {cracky = 1, level = 3},
		sounds = default.node_sound_stone_defaults(),
	})

	aliska.register_craft(
		MOD_NAME..':gems_'..gem_name..'_block',
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ MOD_NAME..':gems_'..gem_name }
	)
	aliska.register_craft(
		MOD_NAME..':gems_'..gem_name..' 9',
		{ 1 },
		{ MOD_NAME..':gems_'..gem_name..'_block' }
	)
end

minetest.register_on_mods_loaded(function()
	for _, gem in ipairs(old_gems) do
		minetest.override_item('default:'..gem, {
			inventory_image = 'aliska_gems_'..gem..'.png',
		})
		minetest.override_item('default:'..gem..'block', {
			tiles = { 'aliska_gems_'..gem..'_block.png' },
		})
	end

	minetest.override_item('default:mese_crystal', {
		inventory_image = 'aliska_gems_mese.png',
	})
	minetest.override_item('default:mese', {
		tiles = { 'aliska_gems_mese_block.png' },
	})
end)

for _, gem in ipairs(new_gems) do
	register_gem(gem)
end
