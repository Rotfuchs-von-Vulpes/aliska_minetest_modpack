function aliska.Set(arr, fill)
	local obj = {}
	fill = fill or true

	for _, item in ipairs(arr) do 
		obj[item] = fill
	end

	return obj
end

function aliska.Map(keys, values)
	local obj = {}

	for i, item in ipairs(keys) do 
		obj[item] = values[i]
	end

	return obj
end

function aliska.find_many_repeted(arrs)
	if #arrs == 1 then
		return arrs[1]
	end
	
	local possibles_items
	local finded_items = {}

	local first_key = true
	for _, arr in ipairs(arrs) do
		if first_key then
			first_key = false
			possibles_items = arr
		else
			for i, item in ipairs(possibles_items) do
				for _, item2 in ipairs(arr) do
					if item == item2 then
						table.insert(finded_items, item)
						break
					end
				end
			end
		end
	end

	return finded_items
end

function aliska.find(arr, key)
	for i, el in ipairs(arr) do
		if el == key then
			return i
		end
	end

	return 0
end

function aliska.search(arr, key)
	for _, el in ipairs(arr) do
		if el == key then
			return true
		end
	end

	return false
end

function aliska.c(str)
	local capitalize = true

	return str:gsub('.', function(char)
		if capitalize then
			capitalize = false
			return char:upper()
		end

		if char == '_' then
			capitalize = true
			return ' '
		end

		return char
	end)
end

function aliska.C(str, name)
	return aliska.c(str)..name
end

function aliska.serialize(val, name, skipnewlines, depth)
	skipnewlines = skipnewlines or false
	depth = depth or 0

	local tmp = string.rep(' ', depth)

	if name then tmp = tmp..name..' = ' end

	if type(val) == 'table' then
		tmp = tmp..'{'..(not skipnewlines and '\n' or '')

		for k, v in pairs(val) do
			tmp =  tmp..aliska.serialize(v, k, skipnewlines, depth + 1)..','..(not skipnewlines and '\n' or '')
		end

		tmp = tmp..string.rep(' ', depth)..'}'
	elseif type(val) == 'number' then
		tmp = tmp..tostring(val)
	elseif type(val) == 'string' then
		tmp = tmp..string.format('%q', val)
	elseif type(val) == 'boolean' then
		tmp = tmp..(val and 'true' or 'false')
	else
		tmp = tmp..'\'[inserializeable datatype:'..type(val)..']\''
	end

	return tmp
end

local function make_table(recipe, ingredients)
	local i = 1
	local j = 1
	local width
	local table

	ingredients[0] = ''

	if #recipe == 1 then 
		width = 2
		table = {{''}}
	elseif #recipe <= 4 then
		width = 3
		table = {{'', ''}, {'', ''}}
	elseif #recipe <= 9 then
		width = 4
		table = {{'', '', ''}, {'', '', ''}, {'', '', ''}}
	else
		return
	end

	for _, num in ipairs(recipe) do
		table[j][i] = ingredients[num]
		i = i + 1
		if i >= width then
			j = j + 1
			i = 1
		end
	end

	return table
end

local function make_recipe(ingredients, quantity)
	local recipe = {}

	for i=1, #ingredients do
		for j=1, quantity[i] do
			table.insert(recipe, i)
		end
	end

	return recipe
end

function aliska.register_craft(output, recipe, ingredients)
	local table = make_table(recipe, ingredients)

	minetest.register_craft({
		output = output,
		recipe = table,
	})
end

function aliska.register_cooking(input, output)
	minetest.register_craft{
		output = output,
		type = 'cooking',
		recipe = input
	}
end

function aliska.register_alloy(ingredients, quantity, output)
	local recipe = make_recipe(ingredients, quantity)
	local table = make_table(recipe, ingredients)
	local output_quantity = 0

	for _, q in ipairs(quantity) do
		output_quantity = output_quantity + q
	end

	if output_quantity > 9 then
		return
	end

	minetest.register_craft{
		output = output..' '..output_quantity,
		recipe = table,
	}
end

function aliska.make_brick_tiles(node)
	local image1 = node..'.png'
	local image2 = node..'_side.png'

	return {
		image2, image2,
		image2, image2,
		image1, image1,
	}
end

function aliska.register_stair_and_slab(subname, recipeitem, groups, images,
	desc_stair, desc_slab, sounds, worldaligntex)
stairs.register_stair(subname, recipeitem, groups, images, desc_stair,
	sounds, worldaligntex)
stairs.register_stair_inner(subname, recipeitem, groups, images, "",
	sounds, worldaligntex, "Inner "..desc_stair)
stairs.register_stair_outer(subname, recipeitem, groups, images, "",
	sounds, worldaligntex, "Outer "..desc_stair)
stairs.register_slab(subname, recipeitem, groups, images, desc_slab,
	sounds, worldaligntex)
end
